FROM daocloud.io/centos:6
MAINTAINER Ice Dragon <517icedragon@gmail.com>

#
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
    phpbrew ext install https://github.com/php-memcached-dev/php-memcached php7 -- --disable-memcached-sasl




