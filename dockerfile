FROM centos:7.4.1708
MAINTAINER xiaodongluo <836696016@qq.com>
RUN mkdir -p /data/software && mkdir -p /usr/local/webserver
ADD repo/ \
/data/software/
WORKDIR /data/software
#安装依赖
RUN mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup && \
mv CentOS7-Base-163.repo /etc/yum.repos.d/CentOS-Base.repo
RUN yum makecache && \
yum -y install gcc gcc-c++\
autoconf wget \
psmisc \
openssl openssl-devel \
gperftools-devel \
tar \
passwd \
openssh-server \
openssh-clients \
initscripts \
unzip pcre pcre-devel zlib zlib-devel git \
libxml2 libxml2-devel curl curl-devel \
libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel \
python-setuptools dos2unix gperf \
libevent libevent-devel bzip2-devel ncurses-devel \
boost libtool boost-devel* libuuid-devel python-sphinx.noarch &&\
yum clean all &&\
rm -rf /var/lib/apt/lists/* &&\
rm -rf /var/cache/yum
#用户账号设置
RUN echo 'root:123465' | chpasswd
RUN /usr/sbin/sshd-keygen
RUN /usr/sbin/groupadd oae &&/usr/sbin/useradd -r -m -s /bin/bash -g oae oae && echo "oae ALL=(ALL) ALL" >> /etc/sudoers && echo 'root:123465' | chpasswd
#安装tengine
RUN wget https://gitee.com/hanlicun/ltmp/raw/master/src/pcre-8.10.tar.gz &&\
tar zxvf pcre-8.10.tar.gz &&rm -f pcre-8.10.tar.gz && \
cd pcre-8.10 &&./configure&& make&&make install && \
cd .. && rm -rf pcre-8.10 && \
wget https://gitee.com/hanlicun/ltmp/raw/master/src/tengine-2.1.2.tar.gz &&\
tar -zxvf tengine-2.1.2.tar.gz && rm -f tengine-2.1.2.tar.gz &&\
cd tengine-2.1.2 && \
./configure --prefix=/usr/local/webserver/tengine --user=oae --group=oae --with-http_stub_status_module --with-http_ssl_module --with-file-aio --with-http_realip_module &&\
make &&make install &&\
cd ../ && rm -rf ./tengine-2.1.2 &&\
wget https://gitee.com/hanlicun/ltmp/raw/master/src/nginx.conf &&\
mv nginx.conf \
/usr/local/webserver/tengine/conf/nginx.conf &&\
wget https://gitee.com/hanlicun/ltmp/raw/master/src/nginx &&\
mv ./nginx /etc/init.d/nginx && \
chmod +x /etc/init.d/nginx
# 安装 Libmcrypt
RUN wget https://gitee.com/hanlicun/ltmp/raw/master/src/libmcrypt-2.5.8.tar.gz &&\
tar zxvf libmcrypt-2.5.8.tar.gz &&rm -f libmcrypt-2.5.8.tar.gz &&\
cd libmcrypt-2.5.8 && \
./configure --prefix=/usr/local && \
make && make install &&\
cd .. && rm -rf libmcrypt-2.5.8
# 安装 PHP7
RUN wget http://cn2.php.net/get/php-7.0.17.tar.gz/from/this/mirror && \
tar zxvf mirror && rm -f php-7.0.17.tar.gz && rm -rf mirror &&\
cd php-7.0.17 && \
./configure --prefix=/usr/local/webserver/php --with-config-file-path=/usr/local/webserver/php/etc --enable-fpm --with-fpm-user=oae --with-fpm-group=oae --with-mysqli --with-pdo-mysql --with-iconv-dir --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl --enable-mbregex --enable-mbstring --enable-ftp --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --without-pear --with-gettext --enable-fileinfo --enable-maintainer-zts && make clean &&make && make install && \
cp ./php.ini-development /usr/local/webserver/php/etc/php.ini && \
cp ./sapi/fpm/init.d.php-fpm.in /etc/init.d/php-fpm &&\
chmod 755 /etc/init.d/php-fpm && \
sed -i '$a chown -R oae:oae /var/run/' /etc/init.d/php-fpm && \
cd /data/software && rm -rf php-7.0.17 && \
sed -i '$aPATH=/usr/local/webserver/php/bin:\$PATH\n export PATH' /etc/profile &&\
source /etc/profile && \
mv /usr/local/webserver/php/etc/php-fpm.conf.default /usr/local/webserver/php/etc/php-fpm.conf &&\
sed -i 's!@sbindir@!/usr/local/webserver/php/sbin!g' /etc/init.d/php-fpm && \
sed -i 's!@sysconfdir@!/usr/local/webserver/php/etc!g' /etc/init.d/php-fpm && \
sed -i 's!@localstatedir@!/var!g' /etc/init.d/php-fpm && \
mv /usr/local/webserver/php/etc/php-fpm.d/www.conf.default \
/usr/local/webserver/php/etc/php-fpm.d/www.conf && \
sed -i 's!127.0.0.1:9000!/var/run/php-fpm.sock!g' /usr/local/webserver/php/etc/php-fpm.d/www.conf && \
ln -s /usr/local/webserver/php/bin/php /usr/local/bin/php
#安装 PHP的Redis扩展
RUN wget https://gitee.com/hanlicun/ltmp/raw/master/src/phpredis.tar.gz &&tar zxvf phpredis.tar.gz && rm -rf phpredis.tar.gz &&cd phpredis && /usr/local/webserver/php/bin/phpize && ./configure --with-php-config=/usr/local/webserver/php/bin/php-config &&make &&make install &&sed -i '$a extension_dir =/usr/local/webserver/php/lib/php/extensions/no-debug-zts-20151012/nextension=redis.so\n' /usr/local/webserver/php/etc/php.ini && cd .. &&rm -rf phpredis
#安装 PHP的mongodb扩展
RUN wget https://gitee.com/hanlicun/ltmp/raw/master/src/mongodb.so && mv mongodb.so \
/usr/local/webserver/php/lib/php/extensions/no-debug-zts-20151012/ && sed -i '$a extension\
=mongodb.so' /usr/local/webserver/php/etc/php.ini
#安装 PHP的memcached扩展
RUN wget https://gitee.com/hanlicun/ltmp/raw/master/src/libmemcached-1.0.18.tar.gz &&tar zxvf \
libmemcached-1.0.18.tar.gz && rm -rf libmemcached-1.0.18.tar.gz &&cd libmemcached-1.0.18/\
&&mkdir -p /usr/local/webserver/libmemcached && ./configure --prefix=/usr/local/webserver/libmemcached &&make && make install && cd ../&& rm -rf libmemcached-1.0.18/ && wget https://gitee.com/hanlicun/ltmp/raw/master/src/memcached-3.0.2.tgz\
&&tar zxvf memcached-3.0.2.tgz && rm -rf memcached-3.0.2.tgz && cd memcached-3.0.2\
&&/usr/local/webserver/php/bin/phpize && ./configure --enable-memcached \
--with-php-config=/usr/local/webserver/php/bin/php-config \
--with-libmemcached-dir=/usr/local/webserver/libmemcached --disable-memcached-sasl && make &&\
make install &&cd ../ && rm -rf memcached-3.0.2/ && sed -i '$a extension =memcached.so' \
/usr/local/webserver/php/etc/php.ini
#安装gearman扩展
RUN wget https://gitee.com/hanlicun/ltmp/raw/master/src/gearmand.tar.gz &&tar zxvf gearmand.tar.gz \
&& rm -rf gearmand.tar.gz && cd gearmand &&./bootstrap.sh -a &&./configure &&make && make \
install && cd .. &&rm -rf gearmand &&wget \
https://gitee.com/hanlicun/ltmp/raw/master/src/gearman.so &&mv gearman.so \
/usr/local/webserver/php/lib/php/extensions/no-debug-zts-20151012/ && sed -i '$a extension\
=gearman.so' /usr/local/webserver/php/etc/php.ini
#安装zmq扩展
RUN wget https://gitee.com/hanlicun/ltmp/raw/master/src/libzmq.tar.gz &&tar zxvf libzmq.tar.gz &&\
rm -rf libzmq.tar.gz && cd libzmq && ./autogen.sh && ./configure && make -j 4 &&make check && \
make install && ldconfig &&cd .. &&wget https://gitee.com/hanlicun/ltmp/raw/master/src/zmq.so \
&&mv zmq.so /usr/local/webserver/php/lib/php/extensions/no-debug-zts-20151012/ && rm -rf libzmq \
&& sed -i '$a extension =zmq.so' /usr/local/webserver/php/etc/php.ini
#或
#wget https://pecl.php.net/get/zmq-1.1.3.tgz && rm -rf zmq-1.1.3.tgz && \
#cd zmq-1.1.3 && /usr/local/webserver/php/bin/phpize &&\
#./configure --prefix=/usr/local/webserver/zmq --with-php-config=/usr/local/webserver/php/bin/php-config &&\
# make && make install &&\
#cd pecl-gearman-master
#/usr/local/webserver/php/bin/phpize
#./configure --prefix=/usr/local/webserver/gearman --with-php-config=/usr/local/webserver/php/bin/php-config
#安装php的ice扩展
RUN cd /data/software && wget https://gitee.com/hanlicun/ltmp/raw/master/src/IcePHP.so &&mv \
IcePHP.so /usr/local/webserver/php/lib/php/extensions/no-debug-zts-20151012/ && wget \
https://gitee.com/hanlicun/ltmp/raw/master/src/Ice-3.6.4.tar.gz &&tar zxvf Ice-3.6.4.tar.gz && mv \
Ice-3.6.4 /opt/ && rm -rf Ice-3.6.4.tar.gz&& sed -i '$a extension =IcePHP.so' \
/usr/local/webserver/php/etc/php.ini && sed -i '$a export LD_LIBRARY_PATH=/opt/Ice-3.6.4/lib64' \
/etc/profile
#Install Composer
RUN wget https://gitee.com/hanlicun/ltmp/raw/master/src/composer &&mv composer \
/usr/local/bin/composer && chmod +x /usr/local/bin/composer && /usr/local/bin/composer config -g\
repo.packagist composer https://packagist.phpcomposer.com
RUN chmod -R 777 /usr/local/webserver/php/var/log/ && chown -R oae:oae /var/run/ && \
mkdir -p /home/oae/web/wwwroot/public/ && \
touch /home/oae/web/wwwroot/public/index.html && \
echo ok > /home/oae/web/wwwroot/public/index.html &&\
echo "<?php phpinfo();?>" > /home/oae/web/wwwroot/public/index.php
#开放端口
EXPOSE 80 22
# 安装 supervisord
RUN easy_install supervisor && \
mkdir -p /usr/local/var/log/supervisord
RUN wget https://gitee.com/hanlicun/ltmp/raw/master/src/supervisord.conf &&\
mv supervisord.conf /etc/supervisord.conf && \
mkdir -p /usr/local/var/run
CMD ["/usr/bin/supervisord","-c", "/etc/supervisord"]
