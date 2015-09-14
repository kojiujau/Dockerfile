FROM ubuntu:latest
MAINTAINER kec  <kec@ematters.com.tw>

RUN export http_proxy="http://id:password@ip/" ;apt-get update;apt-get install -y openssh-server proxychains supervisor rsyslog;sed -e "
/^socks4.*/ d" -i /etc/proxychains.conf ;echo "socks5 ip 38883" >> /etc/proxychains.conf 
RUN echo "*.* @172.17.42.1:514" >> /etc/rsyslog.d/90-networking.conf

# Setting SSH service
RUN mkdir -p /var/run/sshd /var/lock/apache2 /var/run/apache2 /var/log/apache2 /var/log/supervisor
# Default id/pw use root/y
RUN echo 'id:password' | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
 
# Install apache, PHP, and supplimentary programs. curl and lynx-cur are for debugging the container.
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install apache2 libapache2-mod-php5
 
# Enable apache mods.
RUN a2enmod php5
RUN a2enmod rewrite
 
# Update the PHP.ini file, enable <? ?> tags and quieten logging.
RUN sed -i "s/short_open_tag = Off/short_open_tag = On/" /etc/php5/apache2/php.ini
RUN sed -i "s/error_reporting = .*$/error_reporting = E_ERROR | E_WARNING | E_PARSE/" /etc/php5/apache2/php.ini
 
# Manually set up the apache environment variables
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid
 
EXPOSE 80 22
 
# Copy site into place.
ADD www /var/www/site
 
# Update the default apache site with the config we created.
ADD apache-config.conf /etc/apache2/sites-enabled/000-default.conf

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
 
# By default, simply start supervisord.
CMD ["/usr/bin/supervisord"]
