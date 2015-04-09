#!/usr/bin/env bash

# ---------------------------------------------
# ---------- Configuration ----------
# ---------------------------------------------

HOST_NAME="$(hostname)";

MYSQL_DB_NAME='vagrant';
MYSQL_DB_USER='vagrant';
MYSQL_DB_PASSWORD='vagrant';

TOOLS_USER='vagrant';
TOOLS_PASSWORD='vagrant';
TOOLS_PMA_BLOWFISH_KEY='vagrant';

SSL_CSR_INFO="
C=US
ST=$HOST_NAME
O=$HOST_NAME
localityName=$HOST_NAME
commonName=$HOST_NAME
organizationalUnitName=$HOST_NAME
emailAddress=vagrant@$HOST_NAME
";
# ---------------------------------------------
# ---------- Check Setup State ----------
# ---------------------------------------------

if [[ -f /etc/vagrant/.bootstrap-complete ]]; then

	service mysql restart;
	service php5-fpm restart;
	service apache2 restart;

	exit 0; # Nothing more.

fi; # End conditional check.

# ---------------------------------------------
# ---------- Run Setup Routines ----------
# ---------------------------------------------

# Update package repositories.

apt-add-repository multiverse;
apt-get update; # May take a moment.

# Install utilities.

apt-get install zip unzip --yes;

# Install Apache web server.

apt-get install apache2 --yes;
apt-get install apache2-utils --yes;
apt-get install libapache2-mod-fastcgi --yes;

# Configure Apache web server.

a2dismod autoindex -f;
a2dismod negotiation -f;
a2dissite 000-default;

a2enmod mpm_event;

a2enmod auth_basic;

a2enmod authn_core;
a2enmod authn_file;

a2enmod authz_core;
a2enmod authz_host;
a2enmod authz_user;

a2enmod env;
a2enmod setenvif;

a2enmod ssl;
a2enmod socache_shmcb;

a2enmod dir;
a2enmod alias;
a2enmod vhost_alias;
a2enmod rewrite;

a2enmod mime;
a2enmod actions;
a2enmod fastcgi;

a2enmod expires;
a2enmod headers;

a2enmod deflate;
a2enmod filter;

a2enmod info;
a2enmod status;

a2enmod access_compat;

mkdir --parents /var/vagrant/cgi-bin;
echo 'export HOST_NAME="'"$HOST_NAME"'"' >> /etc/apache2/envvars;
ln --symbolic /vagrant/assets/apache/.conf /etc/apache2/conf-enabled/z90.conf;
sed --in-place 's/^\s*SSLProtocol all\s*$/SSLProtocol all -SSLv2 -SSLv3/I' /etc/apache2/mods-enabled/ssl.conf;

mkdir --parents /etc/vagrant/ssl;
openssl genrsa -out /etc/vagrant/ssl/.key 2048;
openssl req -new -subj "$(echo -n "$SSL_CSR_INFO" | tr "\n" "/")" -key /etc/vagrant/ssl/.key -out /etc/vagrant/ssl/.csr -passin pass:'';
openssl x509 -req -days 365 -in /etc/vagrant/ssl/.csr -signkey /etc/vagrant/ssl/.key -out /etc/vagrant/ssl/.crt;

# Install MySQL database server.

echo 'mysql-server mysql-server/root_password password '"$MYSQL_DB_PASSWORD" | debconf-set-selections \
  && echo 'mysql-server mysql-server/root_password_again password '"$MYSQL_DB_PASSWORD" | debconf-set-selections \
	&& apt-get install mysql-server --yes;

mkdir --parents --mode=777 /var/log/mysql;
ln --symbolic /vagrant/assets/mysql/.cnf /etc/mysql/conf.d/z90.cnf;

mysql_install_db; # Install database tables.

mysql --password="$MYSQL_DB_PASSWORD" --execute="GRANT ALL ON *.* TO '$MYSQL_DB_USER'@'localhost' IDENTIFIED BY '$MYSQL_DB_PASSWORD';";
mysql --password="$MYSQL_DB_PASSWORD" --execute="CREATE DATABASE \`$MYSQL_DB_NAME\` CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci';";

mysql --password="$MYSQL_DB_PASSWORD" --execute="DELETE FROM \`mysql\`.\`user\` WHERE \`User\` = '';";
mysql --password="$MYSQL_DB_PASSWORD" --execute="DELETE FROM \`mysql\`.\`user\` WHERE \`User\` = 'root' AND \`Host\` NOT IN ('localhost', '127.0.0.1', '::1');";
mysql --password="$MYSQL_DB_PASSWORD" --execute="DROP DATABASE IF EXISTS \`test\`; DELETE FROM \`mysql\`.\`db\` WHERE \`Db\` = 'test' OR \`Db\` LIKE 'test\\_%';";
mysql --password="$MYSQL_DB_PASSWORD" --execute="FLUSH PRIVILEGES;";

ln --symbolic --force /vagrant/assets/apache/tools/.pma.php /vagrant/assets/apache/tools/pma/config.inc.php;

# Install PHP and PHP process manager.

apt-get install php5-cli --yes;
apt-get install php5-fpm --yes;
apt-get install php5-dev --yes;

apt-get install php5-curl --yes;
apt-get install php5-gd --yes;
apt-get install php5-imagick --yes;
apt-get install php5-json --yes;
apt-get install php5-mysql --yes;

apt-get install php5-mcrypt --yes;
echo 'extension=mcrypt.so' > /etc/php5/cli/conf.d/20-mcrypt.ini;
echo 'extension=mcrypt.so' > /etc/php5/fpm/conf.d/20-mcrypt.ini;

mkdir --parents --mode=777 /var/log/php;
ln --symbolic /vagrant/assets/php/.ini /etc/php5/cli/conf.d/z90.ini;
ln --symbolic /vagrant/assets/php/.ini /etc/php5/fpm/conf.d/z90.ini;
ln --symbolic /vagrant/assets/php/fpm/.conf /etc/php5/fpm/pool.d/z90.conf;
mv /etc/php5/fpm/pool.d/www.conf /etc/php5/fpm/pool.d/www.conf~;

echo '[www]' >> /etc/php5/fpm/pool.d/env.conf \
  && echo "env[MYSQL_DB_HOST] = 'localhost'" >> /etc/php5/fpm/pool.d/env.conf \
  && echo "env[MYSQL_DB_NAME] = '$MYSQL_DB_NAME'" >> /etc/php5/fpm/pool.d/env.conf \
  && echo "env[MYSQL_DB_USER] = '$MYSQL_DB_USER'" >> /etc/php5/fpm/pool.d/env.conf \
  && echo "env[MYSQL_DB_PASSWORD] = '$MYSQL_DB_PASSWORD'" >> /etc/php5/fpm/pool.d/env.conf \
  && echo "env[TOOLS_PMA_BLOWFISH_KEY] = '$TOOLS_PMA_BLOWFISH_KEY'" >> /etc/php5/fpm/pool.d/env.conf;

# Create password file for web-based tools.

mkdir --parents /etc/vagrant/passwds;
htpasswd -cb /etc/vagrant/passwds/.tools "$TOOLS_USER" "$TOOLS_PASSWORD";

# Global environment variables.

echo "MYSQL_DB_HOST='localhost'" >> /etc/environment \
  && echo "MYSQL_DB_NAME='$MYSQL_DB_NAME'" >> /etc/environment \
  && echo "MYSQL_DB_USER='$MYSQL_DB_USER'" >> /etc/environment \
  && echo "MYSQL_DB_PASSWORD='$MYSQL_DB_PASSWORD'" >> /etc/environment \
  && echo "TOOLS_PMA_BLOWFISH_KEY='$TOOLS_PMA_BLOWFISH_KEY'" >> /etc/environment;

# Restart services.

service mysql restart;
service php5-fpm restart;
service apache2 restart;

# Mark setup as being complete.

touch /etc/vagrant/.bootstrap-complete;
