#!/bin/bash

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

compile_iconv() {
    tar zxf ${base_dir}/libiconv-1.14.tar.gz -C ${tmp_dir}
    echo "Compiling iconv..."
    cat > $tmp_dir/build_iconv.sh <<SCRIPT
cd ${tmp_dir}/libiconv-1.14
./configure --prefix=${output_dir} --enable-static=yes --enable-shared=no
sed -i "s+GNULIB_GETS = 1+GNULIB_GETS = 0+g" srclib/Makefile
make
make install
SCRIPT
    sh $tmp_dir/build_iconv.sh > $tmp_dir/build_iconv.log
}

compile_freetype() {
    tar zxf ${base_dir}/freetype-2.9.1.tar.gz -C ${tmp_dir}
    echo "Compiling freetype..."
    cat > $tmp_dir/build_freetype.sh <<SCRIPT
cd ${tmp_dir}/freetype-2.9.1
./configure --prefix=${output_dir} --enable-shared=no
make
make install
SCRIPT
    sh $tmp_dir/build_freetype.sh > $tmp_dir/build_freetype.log
}

compile_openssl() {
    tar zxf ${base_dir}/openssl-1.0.1s.tar.gz -C ${tmp_dir}
    echo "Compiling openssl..."
    cat > $tmp_dir/build_openssl.sh <<SCRIPT
cd ${tmp_dir}/openssl-1.0.1s
./config --prefix=${output_dir}
make
make install
SCRIPT
    sh $tmp_dir/build_openssl.sh > $tmp_dir/build_openssl.log
}

compile_zlib() {
    tar zxf ${base_dir}/zlib-1.2.11.tar.gz -C ${tmp_dir}
    echo "Compiling zlib..."
    cat > $tmp_dir/build_zlib.sh <<SCRIPT
cd ${tmp_dir}/zlib-1.2.11
./configure --prefix=${output_dir} --64
make
make install
SCRIPT
    sh $tmp_dir/build_zlib.sh > $tmp_dir/build_zlib.log
}

compile_curl() {
    tar zxf ${base_dir}/curl-7.21.7.tar.gz -C ${tmp_dir}
    echo "Compiling curl..."
    cat > $tmp_dir/build_curl.sh <<SCRIPT
cd ${tmp_dir}/curl-7.21.7
./configure --prefix=${output_dir} --without-libssh2 \\
--with-ssl=${tmp_dir}/output --with-zlib=${tmp_dir}/output
make
make install
SCRIPT
    sh $tmp_dir/build_curl.sh > $tmp_dir/build_curl.log
}

compile_iconv
compile_freetype
compile_openssl
compile_zlib
compile_curl
