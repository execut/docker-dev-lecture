# Step 1. OS install:
docker-compose up -d
docker-compose exec without-docker-container /bin/bash

# Step 2. Software install
apt-get update && apt-get install -y nginx mariadb-server git

# Step 3. PHP install:
apt-get install -y wget libpspell-dev gcc libsodium-dev libxml2-utils libxml2-dev sqlite libsqlite3-dev libpcre3-dev libbz2-dev libjpeg-dev libpng-dev libxpm-dev libfreetype6-dev libgmp3-dev libmcrypt-dev make freetds-dev libpq-dev libreadline-dev pkg-config libicu-dev g++ autoconf libmagickwand-dev ucf libc-client2007e-dev libc6 unzip unrar libkrb5-dev libc-client-dev libjxr-tools webp libwebp-dev libonig-dev libzip-dev autoconf
#libcurl4-gnutls-dev

# Install openssl old version
cd ~; mkdir /opt/openssl; mkdir /opt/openssl/ssl; sudo ln -s /etc/ssl/certs /opt/openssl/ssl/certs;
wget https://www.openssl.org/source/openssl-1.0.2u.tar.gz;
tar -zxf openssl-1.0.2u.tar.gz --directory /opt/openssl;
cd /opt/openssl/openssl-1.0.2u;
./config --prefix=/opt/openssl --openssldir=/opt/openssl/ssl;
make;
make test;
make install;
mv /usr/bin/openssl /usr/bin/openssl-1.0.2u;
ln -s /usr/local/bin/openssl /usr/bin/openssl;

touch /etc/profile.d/openssl.sh;
echo '#!/bin/sh' > /etc/profile.d/openssl.sh;
echo 'export PATH=/opt/openssl/bin:${PATH}' >> /etc/profile.d/openssl.sh;
echo 'export LD_LIBRARY_PATH=/opt/openssl/lib:${LD_LIBRARY_PATH}' >> /etc/profile.d/openssl.sh;

chmod +x /etc/profile.d/openssl.sh; source /etc/profile.d/openssl.sh;
openssl version;

cd /tmp
PHP_VERSION=7.4.30
wget https://www.php.net/distributions/php-$PHP_VERSION.tar.gz
tar -xvf php-*.tar.gz

cd php-$PHP_VERSION

'./configure'\
    '--prefix=/'\
    '--enable-fpm'\
    '--enable-cli'\
    '--with-readline'\
    '--with-sodium'\
    '--with-pic' '--disable-rpath' '--without-pear' '--with-bz2'\
    '--without-gdbm' '--with-gettext'\
    '--with-gmp' '--with-iconv'\
    '--with-zlib'\
    '--with-openssl'\
    '--with-pear'\
    '--with-layout=GNU' '--enable-exif' '--enable-ftp' '--enable-sockets' '--enable-sysvsem'\
    '--enable-sysvshm' '--enable-sysvmsg' '--with-kerberos' '--enable-shmop' '--enable-calendar'\
    '--enable-xml' '--enable-soap'\
    '--enable-pcntl'\
    '--with-mysqli'\
    '--with-pdo-mysql'\
    '--disable-dba'\
    '--enable-mbstring' '--without-pspell' '--disable-posix' '--disable-sysvmsg'\
    '--disable-sysvshm' '--disable-sysvsem'\
    '--enable-short-tags'\
    '--enable-phpdbg'\
    '--enable-intl'\
    '--enable-bcmath'\
    '--with-zip'\
    '--enable-gd'\
    '--with-freetype'\
    '--with-jpeg'\
    '--with-xpm'\
    '--with-webp'\
    '--with-pspell'
make
make install

# Step 4: XDebug install
cd /tmp
XDEBUG_VERSION=3.1.5
wget http://xdebug.org/files/xdebug-$XDEBUG_VERSION.tgz
tar -xvf xdebug-$XDEBUG_VERSION.tgz
cd xdebug-$XDEBUG_VERSION
apt-get install -y autoconf
phpize
./configure --enable-xdebug
make
cp modules/xdebug.so /lib/php/20*/

# Step 5: Configure php
cd /tmp/php-$PHP_VERSION
cp ./php.ini-development /etc/php.ini
cp /etc/php-fpm.conf.default /etc/php-fpm.conf
cp /configs/www.conf /etc/php-fpm.d/www.conf

cp ./sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
chmod +x /etc/init.d/php-fpm
service php-fpm start

# Step 6: Get sources of project
cd /var/www/html
git clone https://$GITHUB_TOKEN@github.com/$GITHUB_ORGANIZATION/cs-cart
cd cs-cart

# Step 6: Configure nginx
cp /configs/nginx.conf /etc/nginx/sites-enabled/default
service nginx reload

# Step 7: Install database
service mariadb start

# Step 8: Install application
cp /configs/local_conf.php ./
php _tools/restore.php
chmod -R 777 images