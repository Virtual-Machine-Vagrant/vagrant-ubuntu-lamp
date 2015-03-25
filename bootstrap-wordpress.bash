#!/usr/bin/env bash

# ---------------------------------------------
# ---------- Configuration ----------
# ---------------------------------------------

# Nothing to configure at this time.

# ---------------------------------------------
# ---------- Check Setup State ----------
# ---------------------------------------------

if [ -f /etc/vagrant/.wordpress-complete ]; then
	exit 0; # Nothing more to do here.
fi; # End conditional check.

# ---------------------------------------------
# ---------- Run Setup Routines ----------
# ---------------------------------------------

# Download and install the latest version of WordPress.

curl --location --output /tmp/wordpress-latest.zip http://wordpress.org/latest.zip \
	&& unzip -qq -d /tmp/wordpress-latest /tmp/wordpress-latest.zip;
cp --force --recursive /tmp/wordpress-latest/wordpress/* /vagrant-htdocs;
rm -r /tmp/wordpress-latest && rm /tmp/wordpress-latest.zip;

# Configure WordPress using a preset `/wp-config.php` file.

cp --force /vagrant/assets/wordpress/wp-config.php /vagrant-htdocs/wp-config.php;

# Create theme symlinks if possible.

if [ -d /vagrant-wordpress/themes ]; then
	for dir in /vagrant-wordpress/themes/*/; do
		if [ -d "$dir"/"$(basename "$dir")" ]; then
			ln --symbolic "$dir"/"$(basename "$dir")" /vagrant-htdocs/wp-content/themes/"$(basename "$dir")";
		else # Not in a nested sub-directory; i.e., this is the plugin directory.
			ln --symbolic "$dir" /vagrant-htdocs/wp-content/themes/"$(basename "$dir")";
		fi;
	done;
fi;
# Create plugin symlinks if possible.

if [ -d /vagrant-wordpress/plugins ]; then
	for dir in /vagrant-wordpress/plugins/*/; do
		if [ -d "$dir"/"$(basename "$dir")" ]; then
			ln --symbolic "$dir"/"$(basename "$dir")" /vagrant-htdocs/wp-content/plugins/"$(basename "$dir")";
		else # Not in a nested sub-directory; i.e., this is the theme directory.
			ln --symbolic "$dir" /vagrant-htdocs/wp-content/plugins/"$(basename "$dir")";
		fi;
	done;
fi;
# Mark setup as being complete.

touch /etc/vagrant/.wordpress-complete;
