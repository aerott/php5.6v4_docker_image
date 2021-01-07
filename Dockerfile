FROM ubuntu:xenial
# Ref.: https://github.com/lysender/docker-php5.6-ubuntu-xenial

# Install packages
ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8

# Configure services
#ADD ./start-apache2.sh /start-apache2.sh
ADD ./install-composer.sh /install-composer.sh

COPY apache2.conf /bin/
COPY init_container.sh /bin/
COPY hostingstart.html /home/site/wwwroot/hostingstart.html

# Combined RUN commands to reduce layer size
RUN apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository ppa:ondrej/php && \
    apt-get update && \
    apt-get install -y \
    wget \
    #supervisor \
    php5.6 \
    php5.6-cgi \
    php5.6-cli \
    php5.6-common \
    php5.6-fpm \
    php5.6-mysql \
    php5.6-mbstring \
    php5.6-curl \
    php5.6-dev \
    php5.6-gd \
    php5.6-xml \
    php5.6-mcrypt \
    php5.6-xmlrpc \
    php5.6-zip \
    libxrender1  \
    libxext6 \
    libfontconfig1 \
    wkhtmltopdf \
    xvfb \
    git \
    curl \
    apache2 \
    openssh-server \ 
    vim \ 
    tcptraceroute \
    libapache2-mod-php5.6 \
    openssl && \
    apt-get clean && \
    chmod 755 /*.sh && \
    #mkdir -p /etc/supervisor/conf.d && \
    #echo "ServerName localhost" >> /etc/apache2/apache2.conf && \
    phpenmod mcrypt && \
    phpenmod curl && \
    a2enmod rewrite && \
    a2enmod expires && \
    a2enmod headers && \
    a2enmod include && \
    a2enmod deflate && \
    a2enmod env && \
    chmod +x /install-composer.sh && \
    /install-composer.sh && \
    mv composer.phar /usr/bin/composer

RUN \
    chmod 755 /bin/init_container.sh \
    && echo "root:Docker!" | chpasswd \
    && echo "cd /home" >> /etc/bash.bashrc \
    && rm -f /var/log/apache2/* \
    && rmdir /var/lock/apache2 \
    && rmdir /var/run/apache2 \
    && rmdir /var/log/apache2 \
    && chmod 777 /var/log \
    && chmod 777 /var/run \
    && chmod 777 /var/lock \
    && chmod 777 /bin/init_container.sh \
    && cp /bin/apache2.conf /etc/apache2/apache2.conf \
    && rm -rf /var/www/html \
    && rm -rf /var/log/apache2 \
    && mkdir -p /home/LogFiles \
    && ln -s /home/site/wwwroot /var/www/html \
    && ln -s /home/LogFiles /var/log/apache2 

RUN { \
                echo 'error_log=/var/log/apache2/php-error.log'; \
                echo 'display_errors=Off'; \
                echo 'log_errors=On'; \
                echo 'display_startup_errors=Off'; \
                echo 'date.timezone=UTC'; \
                echo 'upload_max_filesize=20M'; \
                echo 'post_max_size=21M'; \
    } > /etc/php/5.6/apache2/php.ini

#ADD ./supervisor-apache2.conf /etc/supervisor/conf.d/apache2.conf
#ADD apache-default.conf /etc/apache2/sites-available/000-default.conf

#VOLUME ["/var/www/html", "/var/log/apache2"]

COPY sshd_config /etc/ssh/

EXPOSE 2222 8080

ENV APACHE_RUN_USER www-data
ENV PHP_VERSION 5.6

ENV PORT 8080
ENV WEBSITE_ROLE_INSTANCE_ID localRoleInstance
ENV WEBSITE_INSTANCE_ID localInstance
ENV PATH ${PATH}:/home/site/wwwroot

WORKDIR /var/www/html

#CMD ["/usr/bin/supervisord", "-n"]

ENTRYPOINT ["/bin/init_container.sh"]