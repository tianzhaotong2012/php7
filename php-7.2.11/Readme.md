## Prepare ##
- yum install -y gcc gcc-c++
- yum install -y autoconf
- yum install -y freetype-devel
- yum -y install ImageMagick-devel
- yum -y install libxml2 libxml2-devel
## Compile ##
- run sh local_build.sh
- cd output
## Install ##
- mv output/* [Destination]
- sh php-install-7.2.11.sh

