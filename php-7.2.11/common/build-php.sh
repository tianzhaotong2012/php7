#!/bin/bash
if [[ $1 == '' ]]; then
    echo 'Usage: sh build-php.sh $install_dir';
    exit 1
fi

rm -rf build
mkdir build
cd build

php_ver=NOT_SET
install_dir=$1
tmp_dir=$PWD
src_dir=$tmp_dir/..
compile_log="$tmp_dir/compile.log"
compile_cores=`grep processor /proc/cpuinfo | wc -l`

tar xzf ${src_dir}/php-$php_ver.tar.gz

cd php-$php_ver

export CFLAGS="-O3 -g"
export CXXFLAGS=$CFLAGS
export CC=/usr/bin/gcc
export CXX=/usr/bin/gcc
export PATH=/usr/bin/gcc:$PATH
export LDFLAGS="-L${src_dir}/third"

if [[ -f $compile_log ]]; then
    rm $compile_log
fi

echo "Compiling PHP $php_ver ..."
{
    ./configure \
        --prefix="${install_dir}/php" \
        --with-config-file-path="${install_dir}/php/etc" \
        --with-config-file-scan-dir="${install_dir}/php/etc/ext" \
        --enable-opcache \
	--enable-bcmath \
        --enable-fpm \
        --with-iconv-dir="${src_dir}/third" \
        --with-iconv="${src_dir}/third" \
        --disable-ipv6 \
        --enable-mbstring \
        --enable-shmop \
        --enable-soap \
        --enable-sockets \
        --enable-sysvsem \
        --enable-pcntl \
        --enable-zip \
        --enable-mysqlnd \
	--with-pdo-mysql=mysqlnd \
	--with-openssl="${src_dir}/third" \
        --with-zlib="${src_dir}/third" \
        --with-pear \
        --with-curl="${src_dir}/third" \
        --with-freetype-dir="${src_dir}/third" \
	--with-libxml-dir=/usr   
 
    ##make -j $compile_cores 
    make
    make install
} > $compile_log

${install_dir}/php/bin/pear config-set ext_dir "${install_dir}/php/ext" system 

install -dm755 "${install_dir}/php/etc/ext/.placeholder"
install -dm755 "${install_dir}/php/ext/.placeholder"

mv -f "${install_dir}/php/sbin/php-fpm" "${install_dir}/php/bin/php-cgi"
install -Dm755 "${src_dir}/php-fpm.sh" "${install_dir}/php/sbin/php-fpm.sh"
sed -i "s+\${WORK_ROOT}+${install_dir}+g" "${install_dir}/php/sbin/php-fpm.sh"

sed -i 's|lib/php/extensions/no-debug-non-zts-[0-9]\+|ext|' ${install_dir}/php/bin/php-config ${install_dir}/php/include/php/main/build-defs.h
sed -i 's|lib/php/extensions/debug-non-zts-[0-9]\+|ext|' ${install_dir}/php/bin/php-config ${install_dir}/php/include/php/main/build-defs.h
find ${install_dir}/php/lib/php/extensions -name "opcache.so" |xargs -i mv {} ${install_dir}/php/ext/
install -Dm644 "${src_dir}/php.ini" "${install_dir}/php/etc/php.ini"
sed -i "s+\${WORK_ROOT}+${install_dir}+g" "${install_dir}/php/etc/php.ini"
install -Dm644 "${src_dir}/php-fpm.conf" "${install_dir}/php/etc/php-fpm.conf"
sed -i "s+\${WORK_ROOT}+${install_dir}+g" "${install_dir}/php/etc/php-fpm.conf"
