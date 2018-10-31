#! /bin/bash

set -e

not() {
    if $@; then
        return 1;
    else
        return 0;
    fi
}

wait_for() {
    local try=$1
    shift
    for ((;try>0;try--)); do
        if $@ ; then
            return 0
        fi
        echo -n .
        sleep 1
    done
    return 1
}

process_exists() {
    local pid=$1
    local bin=$2
    if [[ -d /proc/$pid ]]; then
        local exe=`readlink -f /proc/$pid/exe`
        if [[ $exe == $bin ]]; then
            return 0
        fi
        if [[ ! -e $exe ]]; then
            return 0
        fi
    fi
    return 1
}


PHP_CONF=${WORK_ROOT}/php/etc/php.ini
PHP_FPM_BIN=${WORK_ROOT}/php/bin/php-cgi
PHP_FPM_CONF=${WORK_ROOT}/php/etc/php-fpm.conf
PHP_FPM_PID=${WORK_ROOT}/php/var/php-fpm.pid
WORK_LOG_PATH=${WORK_ROOT}/php/log
PHP_LOG_PATH=$WORK_LOG_PATH
PHP_OPTS="-c $PHP_CONF -p ${WORK_ROOT}/php --fpm-config $PHP_FPM_CONF"
export MAGICK_CONFIGURE_PATH=${WORK_ROOT}


PHP_LOG_LIST="php-error.log php-fpm.log"
mstart() {
    if [ ! -w "$PHP_LOG_PATH" ] ; then
        mkdir -p "$PHP_LOG_PATH"
    fi
    for i in $PHP_LOG_LIST
    do  
        if [ ! -f "$PHP_LOG_PATH/$i" ] ; then
            touch "$PHP_LOG_PATH/$i"
        fi
    done

    echo -n "Starting php_fpm "
    if PHP_INI_SCAN_DIR=${WORK_ROOT}/php/etc/ext $PHP_FPM_BIN $PHP_OPTS; then
        sleep 1
        if wait_for 30 test -f $PHP_FPM_PID; then
            echo "done"
        else
            echo "failed"
            exit 1
        fi
    else
        echo "failed"
        exit 1
    fi

}

mstop() {
    if [ ! -r $PHP_FPM_PID ] ; then
        return
    fi
    local pid=`head $PHP_FPM_PID`
    if ! process_exists $pid $PHP_FPM_BIN; then
        rm $PHP_FPM_PID
        return
    fi

    if [[ $1 == 'quit' ]]; then
        echo -n "Shutting down php_fpm gracefully "
        kill -QUIT `cat $PHP_FPM_PID`
    else
        echo -n "Shutting down php_fpm "
        kill -TERM `cat $PHP_FPM_PID`
    fi

    if wait_for 10 "not process_exists $pid $PHP_FPM_BIN"; then
        echo 'done'
    else
        echo 'failed'
        exit 1
    fi
}

case "$1" in
    start)
        mstop
        mstart
    ;;

    stop)
        mstop
    ;;

    quit)
        mstop quit
    ;;

    restart)
        mstop
        mstart
    ;;

    reload)
        echo -n "Reload service php-fpm "

        if [ ! -r $PHP_FPM_PID ] ; then
            echo "warning, no pid file found - php-fpm is not running ?"
            exit 1
        fi

        kill -USR2 `cat $PHP_FPM_PID`

        echo " done"
    ;;

    logrotate)
        echo -n "Re-opening php-fpm log file "

        if [ ! -r $PHP_FPM_PID ] ; then
            echo "warning, no pid file found - php-fpm is not running ?"
            exit 1
        fi

        kill -USR1 `cat $PHP_FPM_PID`

        echo " done"
    ;;

    *)
        echo "Usage: $0 {start|stop|quit|restart|reload|logrotate}"
        exit 1
    ;;

esac
