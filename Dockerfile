############################################################
# Dockerfile for a simple php-nginx configuration that works with composer
############################################################

FROM phusion/baseimage:0.9.16
MAINTAINER David Heidrich (me@bowlingx.com)

ENV HOME /root

ENV TIMEZONE Europe/Berlin
ENV APP_ROOT /var/www
ENV COMPOSER_HOME /var/www

RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

CMD ["/sbin/my_init"]

# Nginx-PHP Installation
RUN apt-get update
RUN apt-get install -y vim curl wget build-essential python-software-properties
RUN add-apt-repository -y ppa:ondrej/php5
RUN add-apt-repository -y ppa:nginx/stable
RUN apt-get update
RUN apt-get install -y --force-yes libcurl4-gnutls-dev php5-cli php5-fpm php5-mysql php5-pgsql php5-sqlite php5-curl\
		       php5-gd php5-mcrypt php5-intl php5-imap php5-tidy php-pear php5-dev

# Install Additional PECL modules:
Run apt-get install -y --force-yes libxml2-dev

# Solr support:
RUN pecl install -f solr-1.0.2

# Install VCS stuff
RUN apt-get install -y --force-yes git mercurial

# http://askubuntu.com/questions/76808/how-to-use-variables-in-sed-command
# Setup timezone
RUN sed -i "s|;date.timezone =.*|date.timezone = $TIMEZONE|" /etc/php5/fpm/php.ini
RUN sed -i "s|;date.timezone =.*|date.timezone = $TIMEZONE|" /etc/php5/cli/php.ini

# Install Composer:
RUN curl -s http://getcomposer.org/installer | php
RUN sudo mv composer.phar /usr/local/bin/composer
RUN sudo chmod +x /usr/local/bin/composer

RUN apt-get install -y nginx

RUN echo "daemon off;" >> /etc/nginx/nginx.conf
RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php5/fpm/php-fpm.conf
RUN sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php5/fpm/php.ini

RUN mkdir -p        /var/www
ADD docker/default   /etc/nginx/sites-available/default
RUN mkdir           /etc/service/nginx
ADD docker/nginx.sh  /etc/service/nginx/run
RUN chmod +x        /etc/service/nginx/run
RUN mkdir           /etc/service/phpfpm
ADD docker/phpfpm.sh /etc/service/phpfpm/run
RUN chmod +x        /etc/service/phpfpm/run

# Add github and bitbucket keys to known hosts
RUN ssh-keyscan -t rsa github.com 2>&1 >> /root/.ssh/known_hosts
RUN ssh-keyscan -t rsa bitbucket.org 2>&1 >> /root/.ssh/known_hosts

# Setup configuration
ADD docker/etc  /etc

EXPOSE 80
# End Nginx-PHP

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*