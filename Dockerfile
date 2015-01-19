# Set the base image to debian
FROM debian:jessie

# File Author / Maintainer
MAINTAINER William Jones <billy@freshjones.com>

ENV DEBIAN_FRONTEND noninteractive
ENV MYSQL_USER admin
ENV MYSQL_PASS welcome


# Update the repository sources list
RUN apt-get update && \
    apt-get install -y \
    build-essential \
    curl \
    nano \
    git \
    nginx \
    supervisor

#install mysql
RUN apt-get install -y \
    mysql-server    

# Remove pre-installed database
RUN rm -rf /var/lib/mysql/*

# MySQL configuration
#ADD mysql/my.cnf /etc/mysql/conf.d/my.cnf
#RUN sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/my.cnf

#install php fpm
RUN apt-get install -y \
    php5-fpm \
    php5-mysql \ 
    php5-gd \
    php5-memcached \ 
    php5-imap \
    php5-mcrypt \
    php5-xmlrpc

# php-fpm config
RUN sed -i -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php5/fpm/php.ini && \
    sed -i -e "s/upload_max_filesize\s*=\s*2M/upload_max_filesize = 100M/g" /etc/php5/fpm/php.ini && \
    sed -i -e "s/post_max_size\s*=\s*8M/post_max_size = 100M/g" /etc/php5/fpm/php.ini && \
    sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php5/fpm/php-fpm.conf && \
    sed -i -e "s/;catch_workers_output\s*=\s*yes/catch_workers_output = yes/g" /etc/php5/fpm/pool.d/www.conf

#RUN find /etc/php5/cli/conf.d/ -name "*.ini" -exec sed -i -re 's/^(\s*)#(.*)/\1;\2/g' {} \;

#install composer
RUN curl -sS https://getcomposer.org/installer | php && \
mv composer.phar /usr/local/bin/composer

#copy supervisor conf
COPY supervisor/supervisor.conf /etc/supervisor/conf.d/supervisord.conf

# Create log directories
RUN mkdir -p /var/log/supervisor

# set daemon to off
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

#add sites enabled dir
ADD sites-enabled/ /etc/nginx/sites-enabled/

#add elliesite app
RUN git clone -b 0.1 --single-branch https://github.com/freshjones/ellie_admin_webapp.git /app

#install composer components
RUN cd /app && \
    composer config -g github-oauth.github.com  b5a3ac9fb28d24911e1a4b0837bde70b9cbc696f && \
    composer install --prefer-dist

#copy the .env variables
RUN cp /app/.env.example /app/.env

#change permissions on the app storage folder
RUN chown -R www-data:www-data /app/storage

#change permissions on the mysqld folder
RUN chown mysql:mysql /var/lib/mysql/

# clean apt cache
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

#expose port 80
EXPOSE 80

#start supervisor
CMD ["/usr/bin/supervisord"]

