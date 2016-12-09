FROM daocloud.io/centos:6
MAINTAINER Ice Dragon <517icedragon@gmail.com>

#install nginx/php-5.3/phpbrew/php-7.1 +default +mysql +pdo +fpm +curl +memcached
RUN yum install -y gcc \
    libxml2-devel \
    libxslt-devel \
    bzip2-devel \
    m4 \
    autoconf \
    libcurl-devel \
    libmemcached-devel \
    cyrus-sasl-devel \
    epel-release \
    libmcrypt \
    libmcrypt-devel \
    mcrypt \
    mhash \
    readline-devel \
    openssl* \
    wget \
    gcc+ \
    gcc-c++ \
    libtool && ln -s /usr/lib64/libssl.so /usr/lib/ && \
    rpm -ivh http://nginx.org/packages/centos/6/noarch/RPMS/nginx-release-centos-6-0.el6.ngx.noarch.rpm \
    && yum install -y nginx && yum install -y php && \
    curl -L -O https://github.com/phpbrew/phpbrew/raw/master/phpbrew && \
    chmod +x phpbrew && \
    mv phpbrew /usr/bin/phpbrew && \
    cd ~ && phpbrew init && \
    echo "[[ -e ~/.phpbrew/bashrc ]] && source ~/.phpbrew/bashrc" >> ~/.bashrc && \
    source ~/.phpbrew/bashrc && \
    wget http://www.atomicorp.com/installers/atomic && \
    sh ./atomic && \
    yum  install -y  php-mcrypt  libmcrypt  libmcrypt-devel && \
    phpbrew install php-7.1.0 as php-7.1 +default +mysql +pdo +fpm +curl && \
    phpbrew switch php-7.1 && \
    wget https://launchpad.net/libmemcached/1.0/1.0.18/+download/libmemcached-1.0.18.tar.gz && \
    tar -zxvf libmemcached-1.0.18.tar.gz && \
    cd libmemcached-1.0.18 && \
    ./configure && \
    make && \
    make install && \
    phpbrew ext install https://github.com/php-memcached-dev/php-memcached php7 -- --disable-memcached-sasl && \
    # Update the php-fpm config file, php.ini enable <? ?> tags and quieten logging.
    sed -i "s/listen = /root/.phpbrew/php/php-7.1/var/run/php-fpm.sock/listen = 127.0.0.1:9000/" /root/.phpbrew/php/php-7.1/etc/php-fpm.d/www.conf && \
    sed -i "s/short_open_tag = Off/short_open_tag = On/" /root/.phpbrew/php/php-7.1/etc/php.ini && \
    mkdir -p /etc/nginx/vhosts && rm -f /etc/nginx/nginx.conf

# Manually set up the nginx log dir,php.ini and php-fpm config file environment variables
ENV NGINX_LOG_DIR /var/log/nginx
ENV PHPINI_FILE_PAHT /root/.phpbrew/php/php-7.1/etc
ENV PHPFPM_FILE_PATH /root/.phpbrew/php/php-7.1/etc/php-fpm.d

# Expose nginx
EXPOSE 80

# Update the default nginx site with the config we created.
ADD config/nginx.conf /etc/nginx/nginx.conf
ADD config/upstream.conf.enable /etc/nginx/conf.d/upstream.conf.enable
ADD config/vhosts/* /etc/nginx/vhosts/

# start-up nginx and fpm
CMD service nginx start && phpbrew use php-7.1 && phpbrew fpm start


