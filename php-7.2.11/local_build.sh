#!/bin/sh

set -e

base_dir=$(cd `dirname $0` && pwd)
output_dir=$base_dir/output
tmp_dir=$base_dir/.tmp
third_dir=$base_dir/third
versions=(
    '7.2.11'
)

rm -rf $output_dir
mkdir $output_dir

for ver in ${versions[*]}; do
	sh $third_dir/build-third.sh
	cd $base_dir
	rm -rf $tmp_dir
    	mkdir $tmp_dir
	cp -rf common/* $tmp_dir/
    	cp -rf $ver/* $tmp_dir/
	cd $tmp_dir
	ln -s $third_dir/.output third
	sed -i "s+^php_ver=.*+php_ver=$ver+g" build-php.sh
	install_dir=$tmp_dir/install
	mkdir $install_dir
	sh build-php.sh $install_dir
	cd $install_dir
	tar czf $output_dir/php-bin-$ver.tar.gz *
	echo "Release php $ver binary success"
	install -Dm644 "${base_dir}/common/php_install" "${output_dir}/php-install-$ver.sh"
	sed -i "s+\${WORK_ROOT}+${install_dir}+g" "${output_dir}/php-install-$ver.sh"
	sed -i "s+\${PHP_VER}+${ver}+g" "${output_dir}/php-install-$ver.sh"
done
