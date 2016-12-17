FROM daocloud.io/centos:6
MAINTAINER Ice Dragon <517icedragon@gmail.com>

#install nginx/php-5.3/phpbrew/php-7.1 +default +mysql +pdo +fpm +curl +memcached
RUN yum install -y sudo-devel && \
    useradd land && \
    sed -i '$a land    ALL=(ALL)       NOPASSWD:ALL' /etc/sudoers

USER land

RUN sudo yum install -y \
    gcc \
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
    libtool && sudo ln -s /usr/lib64/libssl.so /usr/lib/ && \
    sudo rpm -ivh http://nginx.org/packages/centos/6/noarch/RPMS/nginx-release-centos-6-0.el6.ngx.noarch.rpm \
    && sudo yum install -y nginx && sudo yum install -y php && \
    curl -L -O https://github.com/phpbrew/phpbrew/raw/master/phpbrew && \
    chmod +x phpbrew && \
    sudo mv phpbrew /usr/bin/phpbrew && \
    phpbrew init --root=/home/land && \
    echo "[[ -e /home/land/.phpbrew/bashrc ]] && source /home/land/.phpbrew/bashrc" >> /home/land/.bashrc && \
    source /home/land/.phpbrew/bashrc && \
    wget http://www.atomicorp.com/installers/atomic && \
    sh ./atomic && \
    sudo yum  install -y  php-mcrypt  libmcrypt  libmcrypt-devel supervisor openssh-server git && \
    phpbrew install php-7.1.0 as php-7.1 +default +mysql +pdo +fpm +curl && \
    phpbrew switch php-7.1 && \
    wget https://launchpad.net/libmemcached/1.0/1.0.18/+download/libmemcached-1.0.18.tar.gz && \
    tar -zxvf libmemcached-1.0.18.tar.gz && \
    cd libmemcached-1.0.18 && \
    ./configure && \
    make && \
    sudo make install && \
    phpbrew ext install https://github.com/php-memcached-dev/php-memcached php7 -- --disable-memcached-sasl && \
    # Update the php-fpm config file, php.ini enable <? ?> tags and quieten logging.
    sed -i "s/listen = /home/land\/\.phpbrew\/php\/php-7\.1\/var\/run\/php-fpm\.sock/listen = 127\.0\.0\.1:9000/" /home/land/.phpbrew/php/php-7.1/etc/php-fpm.d/www.conf && \
    sed -i "s/short_open_tag = Off/short_open_tag = On/" /home/land/.phpbrew/php/php-7.1/etc/php.ini && \
    sudo mkdir -p /etc/nginx/vhosts && sudo rm -f /etc/nginx/nginx.conf && \
    # Config ssh login container
    sudo sed -i "s/#RSAAuthentication yes/RSAAuthentication yes/" /etc/ssh/sshd_config && \
    sudo sed -i "s/#PubkeyAuthentication yes/PubkeyAuthentication yes/" /etc/ssh/sshd_config && \
    ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key -P '' && \
    ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -P '' && \
    ## Public keys dir
    sudo mkdir -p /home/land/.ssh/id_rsa.pub/


# Manually set up the nginx log dir,php.ini and php-fpm config file environment variables
ENV NGINX_LOG_DIR /var/log/nginx
ENV PHPINI_FILE_PAHT /home/land/.phpbrew/php/php-7.1/etc
ENV PHPFPM_FILE_PATH /home/land/.phpbrew/php/php-7.1/etc/php-fpm.d

# Expose nginx ssh
EXPOSE 80
EXPOSE 22

# Update the default nginx site with the config we created.
ADD config/nginx.conf /etc/nginx/nginx.conf
ADD config/upstream.conf.enabled /etc/nginx/conf.d/upstream.conf.enabled
ADD config/vhosts/* /etc/nginx/vhosts/
# Update the enable public keys
ADD config/id_rsa/*.pub.enabled /home/land/.ssh/id_rsa.pub/

WORKDIR /home/land
# start-up nginx and fpm and ssh
CMD sudo service nginx start && \
    cd /home/land && \
    phpbrew init --root=/home/land && \
    [[ -e /home/land/.phpbrew/bashrc ]] && \
    source /home/land/.phpbrew/bashrc && \
    phpbrew use php-7.1 && \
    phpbrew fpm start && \
    cat /home/land/.ssh/id_rsa.pub/*.pub.enabled > /home/land/.ssh/authorized_keys && \
    sudo chmod 600 /home/land/.ssh/authorized_keys && \
    sudo /usr/sbin/sshd -D


