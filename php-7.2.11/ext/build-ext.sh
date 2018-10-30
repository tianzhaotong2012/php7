#!/bin/bash

if [[ $1 == '' ]]; then
    echo 'Usage: sh build-php-ext.sh $php_home'
    exit 1
fi

php_home=$1

export CC=/usr/bin/gcc
export CXX=/usr/bin/gcc
export CFLAGS="-g -O2 -fPIC"
export PATH=/usr/bin/gcc:$PATH

base_dir=$(cd `dirname $0` && pwd)
output_dir=$base_dir/.output
tmp_dir=$base_dir/.tmp

rm -rf $output_dir
rm -rf $tmp_dir
mkdir -p $output_dir
mkdir -p $tmp_dir

tar zxf ${base_dir}/php7.2.11-mysqli.tar.gz -C ${tmp_dir}
mkdir ${tmp_dir}/php7.2.11-mysqli/ext
tar zxf ${base_dir}/mysqlnd.tar.gz  -C ${tmp_dir}/php7.2.11-mysqli/ext
cd ${tmp_dir}/php7.2.11-mysqli
${php_home}/bin/phpize
./configure --with-php-config=${php_home}/bin/php-config 
make clean
make

cp ${tmp_dir}/php7.2.11-mysqli/modules/mysqli.so ${output_dir}/mysqli.so
cp ${output_dir}/mysqli.so ${php_home}/ext
install -Dm644 "${tmp_dir}/php7.2.11-mysqli/mysqli.ini" "${php_home}/etc/ext/mysqli.ini"

install -Dm644 "${base_dir}/opcache.ini" "${php_home}/etc/ext/opcache.ini"
