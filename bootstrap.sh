#!/usr/bin/env bash
 
# http://www.inanzzz.com/index.php/post/lpwy/accessing-vagrant-virtual-machine-from-the-browser-of-host-machine

# BEGIN ########################################################################
echo -e "-- ------------------ --\n"
echo -e "-- BEGIN BOOTSTRAPING --\n"
echo -e "-- ------------------ --\n"

# BOX ##########################################################################
echo -e "-- Updating packages list\n"
apt-get update -y -qq
 
# NTP #########################################################################
echo -e "-- Installing Network Time protocol \n"
apt-get install -y ntp
apt-get -y upgrade 

# GIT and Curl #########################################################################
echo -e "-- Installing Curl and Git\n"
apt-get install -y curl git 

# PHP #########################################################################
echo -e "-- Adding PHP7.1 repo to apt\n"
sudo apt-get -y install ca-certificates apt-transport-https
wget -q https://packages.sury.org/php/apt.gpg -O- | sudo apt-key add - 
sudo echo "deb https://packages.sury.org/php/ stretch main" | tee /etc/apt/sources.list.d/php7dot1.list
sudo apt-get update -y -qq

echo -e "-- Installing PHP7.3 \n"
sudo apt-get install -y php7.3
echo -e "-- Installing extensions for PHP7.3 \n"
apt-get install -y php7.3-bcmath php7.3-common php7.3-ctype php7.3-curl php7.3-dom php7.3-gd php7.3-intl php7.3-json php7.3-mbstring php7.3-mysqli php7.3-opcache php7.3-soap php7.3-xdebug php7.3-xml php7.3-xsl php7.3-zip 
echo -e "-- PHP7.1 installed \n"

echo "xdebug.profiler_enable_trigger=1" >> /etc/php/7.3/mods-available/xdebug.ini 
echo "xdebug.profiler_enable=0" >> /etc/php/7.3/mods-available/xdebug.ini 
echo "xdebug.remote_port=9000" >> /etc/php/7.3/mods-available/xdebug.ini 
echo "xdebug.remote_enable=1" >> /etc/php/7.3/mods-available/xdebug.ini 
echo "xdebug.remote_host=" >> /etc/php/7.3/mods-available/xdebug.ini 
echo -e "-- XDEBUG configured \n"


# Composer #########################################################################
echo -e "-- Installing Composer\n"
php -r "copy('https://getcomposer.org/installer', '/tmp/composer-setup.php');"
php -r "if (hash_file('SHA384', '/tmp/composer-setup.php') === 'c31c1e292ad7be5f49291169c0ac8f683499edddcfd4e42232982d0fd193004208a58ff6f353fde0012d35fdd72bc394') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('/tmp/composer-setup.php'); } echo PHP_EOL;"
php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer 
php -r "unlink('/tmp/composer-setup.php');"

# VARIABLES ####################################################################
echo -e "-- Moving on to Apache\n"
echo -e "-- Setting global variables\n"
APACHE_CONFIG=/etc/apache2/apache2.conf
VIRTUAL_HOST=localhost
DOCUMENT_ROOT=/var/www/html/magento2/pub
 
# APACHE #######################################################################
echo -e "-- Installing Apache web server\n"
apt-get install -y apache2

echo -e "-- Enabling rewrite\n"
a2enmod rewrite
echo -e "-- Adding ServerName to Apache config\n"
grep -q "ServerName ${VIRTUAL_HOST}" "${APACHE_CONFIG}" || echo "ServerName ${VIRTUAL_HOST}" >> "${APACHE_CONFIG}"
 
echo -e "-- Allowing Apache override to all\n"
sed -i "s/AllowOverride None/AllowOverride All/g" ${APACHE_CONFIG}
 
echo -e "-- Restarting Apache web server\n"
service apache2 restart

echo -e "-- Set open permissions for Apache web server's docroot\n"
chown -R www-data:www-data /var/www/

# Maria-DB Server #######################################################################
echo -e "-- Installing MariadB Server\n"
echo -e "-- Setting global variables\n"
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y mariadb-server
mysql -uroot -e "CREATE DATABASE magento2;"
mysql -uroot -e "GRANT ALL PRIVILEGES ON magento2.* TO vagrant@localhost IDENTIFIED BY 'hashi'"


# ElasticSearch #########################################################################
echo -e "-- Installing ElasticSearch 6.x \n"
mkdir /usr/lib/jvm 
tar -C /usr/lib/jvm -zxvf /vagrant/jdk-8u261-linux-x64.tar.gz 

echo "JAVA_HOME=\"/usr/lib/jvm/jdk1.8.0_261\"" | tee /etc/environment 
update-alternatives --install "/usr/bin/java" "java" "/usr/lib/jvm/jdk1.8.0_261/bin/java" 0
update-alternatives --install "/usr/bin/javac" "javac" "/usr/lib/jvm/jdk1.8.0_261/bin/javac" 0
update-alternatives --set java /usr/lib/jvm/jdk1.8.0_261/bin/java
update-alternatives --set javac /usr/lib/jvm/jdk1.8.0_261/bin/javac


wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
apt-get install -y apt-transport-https
echo "deb https://artifacts.elastic.co/packages/6.x/apt stable main" | tee -a /etc/apt/sources.list.d/elastic-6.x.list
apt-get update
apt-get install elasticsearch
service elasticsearch start
/usr/share/elasticsearch/bin/elasticsearch-plugin install analysis-phonetic
/usr/share/elasticsearch/bin/elasticsearch-plugin install analysis-icu 
service elasticsearch restart 

# Magento File System Owner #######################################################################
echo -e "-- Creating the Magento file system owner\n"
adduser magento2_user --gecos "Magento Local,,," --disabled-password
echo "magento2_user:magento2PW" | sudo chpasswd 

echo -e "-- Adding the Magento file system owner to the web server group\n"
usermod -g www-data magento2_user
service apache2 restart

# END ##########################################################################
echo -e "-- ---------------- --"
echo -e "-- END BOOTSTRAPING --"
echo -e "-- ---------------- --"

UPDATE mysql.user SET plugin = '' WHERE plugin = 'unix_socket';
FLUSH PRIVILEGES;
