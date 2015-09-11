#!/usr/bin/env bash

# ---------------------------------------------
# ---------- Configuration --------------------
# ---------------------------------------------

HOST_NAME="$(hostname)".vm;

MYSQL_DB_HOST='localhost';
MYSQL_DB_NAME='vagrant';
MYSQL_DB_USER='vagrant';
MYSQL_DB_PASSWORD='vagrant';

TOOLS_USER='vagrant';
TOOLS_PASSWORD='vagrant';
TOOLS_PMA_BLOWFISH_KEY='vagrant';

SSL_CSR_INFO="
C=US
ST=$HOST_NAME
L=$HOST_NAME
O=$HOST_NAME
OU=$HOST_NAME
CN=$HOST_NAME
emailAddress=vagrant@$HOST_NAME
";
SSL_CSR_ALTNAMES="
DNS:$HOST_NAME
DNS:*.$HOST_NAME
";

# ---------------------------------------------
# ---------- Functions ------------------------
# ---------------------------------------------

. /vagrant/assets/bash/funcs.bash;

# ---------------------------------------------
# ---------- Check Setup State ----------------
# ---------------------------------------------

if [[ -f /etc/vagrant/.bootstrap-complete ]]; then

	service mysql restart;
	service php5-fpm restart;
	service apache2 restart;

  exit 0; # Nothing more.

fi; # End conditional check.

# ---------------------------------------------
# ---------- Run Setup Routines ---------------
# ---------------------------------------------

# Update package repositories.

apt-add-repository multiverse;
apt-get update; # May take a moment.

# Install utilities.

apt-get install git --yes;
apt-get install zip unzip --yes;
apt-get install apache2-utils --yes;

# Global environment variables.

echo "MYSQL_DB_HOST='$MYSQL_DB_HOST'" >> /etc/environment;
echo "MYSQL_DB_NAME='$MYSQL_DB_NAME'" >> /etc/environment;
echo "MYSQL_DB_USER='$MYSQL_DB_USER'" >> /etc/environment;
echo "MYSQL_DB_PASSWORD='$MYSQL_DB_PASSWORD'" >> /etc/environment;
echo "TOOLS_PMA_BLOWFISH_KEY='$TOOLS_PMA_BLOWFISH_KEY'" >> /etc/environment;

# Generate an SSL certificate.

mkdir --parents /etc/vagrant/ssl;

export OPENSSL_CSR_ALTNAMES; # Needed by config file.
OPENSSL_CSR_ALTNAMES="$(echo -n "$SSL_CSR_ALTNAMES" | trim | tr '\n' ',')";

cp /etc/ssl/openssl.cnf /etc/ssl/vagrant-ss-openssl.cnf;
perl -i -pe 's/^#\s*(req_extensions\s)/$1/m' /etc/ssl/vagrant-ss-openssl.cnf;
perl -i -pe 's/^#\s*(copy_extensions\s)/$1/m' /etc/ssl/vagrant-ss-openssl.cnf;
perl -i -pe 's/^(\[\s*v3_req\s*\])$/$1\nsubjectAltName=\$ENV::OPENSSL_CSR_ALTNAMES/m' /etc/ssl/vagrant-ss-openssl.cnf;

openssl genrsa -out /etc/vagrant/ssl/.key 2048; # Generate key.

openssl req -new -subj /"$(echo -n "$SSL_CSR_INFO" | trim | tr '\n' '/')" \
  -key /etc/vagrant/ssl/.key -out /etc/vagrant/ssl/.csr -passin pass:'' \
  -config /etc/ssl/vagrant-ss-openssl.cnf -extensions v3_req;

openssl x509 -req -days 365 -in /etc/vagrant/ssl/.csr \
  -signkey /etc/vagrant/ssl/.key -out /etc/vagrant/ssl/.crt \
  -extfile /etc/ssl/vagrant-ss-openssl.cnf -extensions v3_req;

# Generate user/pass for web-based tools.

mkdir --parents /etc/vagrant/passwds;
htpasswd -cb /etc/vagrant/passwds/.tools "$TOOLS_USER" "$TOOLS_PASSWORD";

# Install Apache web server.

apt-get install apache2 --yes;
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

# Install MySQL database server.

mkdir --parents --mode=777 /var/log/mysql;

echo 'mysql-server mysql-server/root_password password '"$MYSQL_DB_PASSWORD" | debconf-set-selections \
  && echo 'mysql-server mysql-server/root_password_again password '"$MYSQL_DB_PASSWORD" | debconf-set-selections \
  && apt-get install mysql-server --yes;

ln --symbolic /vagrant/assets/mysql/.cnf /etc/mysql/conf.d/z90.cnf;

mysql_install_db; # Install database tables.

mysql --password="$MYSQL_DB_PASSWORD" --execute="GRANT ALL ON *.* TO '$MYSQL_DB_USER'@'localhost' IDENTIFIED BY '$MYSQL_DB_PASSWORD';";
mysql --password="$MYSQL_DB_PASSWORD" --execute="CREATE DATABASE \`$MYSQL_DB_NAME\` CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci';";

mysql --password="$MYSQL_DB_PASSWORD" --execute="DELETE FROM \`mysql\`.\`user\` WHERE \`User\` = '';";
mysql --password="$MYSQL_DB_PASSWORD" --execute="DELETE FROM \`mysql\`.\`user\` WHERE \`User\` = 'root' AND \`Host\` NOT IN ('localhost', '127.0.0.1', '::1');";
mysql --password="$MYSQL_DB_PASSWORD" --execute="DROP DATABASE IF EXISTS \`test\`; DELETE FROM \`mysql\`.\`db\` WHERE \`Db\` = 'test' OR \`Db\` LIKE 'test\\_%';";
mysql --password="$MYSQL_DB_PASSWORD" --execute="FLUSH PRIVILEGES;";

# Install phpMyAdmin for MySQL adminstration.

git clone https://github.com/phpmyadmin/phpmyadmin /usr/local/src/pma --branch=STABLE --depth=1;
ln --symbolic /vagrant/assets/tools/.pma.php /usr/local/src/pma/config.inc.php;
ln --symbolic /usr/local/src/pma /vagrant/assets/tools/pma;

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

echo '[www]' >> /etc/php5/fpm/pool.d/env.conf;
echo "env[MYSQL_DB_HOST] = 'localhost'" >> /etc/php5/fpm/pool.d/env.conf;
echo "env[MYSQL_DB_NAME] = '$MYSQL_DB_NAME'" >> /etc/php5/fpm/pool.d/env.conf;
echo "env[MYSQL_DB_USER] = '$MYSQL_DB_USER'" >> /etc/php5/fpm/pool.d/env.conf;
echo "env[MYSQL_DB_PASSWORD] = '$MYSQL_DB_PASSWORD'" >> /etc/php5/fpm/pool.d/env.conf;
echo "env[TOOLS_PMA_BLOWFISH_KEY] = '$TOOLS_PMA_BLOWFISH_KEY'" >> /etc/php5/fpm/pool.d/env.conf;

# Mount a RAM disk partition.

mkdir --parents /dev/shm/ramdisk;
echo 'tmpfs /dev/shm/ramdisk tmpfs defaults,size=50% 0 0' >> /etc/fstab;
mount -a; # Mount the new partition.

# Start/restart services.

service mysql restart;
service php5-fpm restart;
service apache2 restart;

# Mark setup as being complete.

mkdir --parents /etc/vagrant;
touch /etc/vagrant/.bootstrap-complete;
