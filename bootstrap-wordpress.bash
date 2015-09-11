#!/usr/bin/env bash

# ---------------------------------------------
# ---------- Configuration --------------------
# ---------------------------------------------

# Nothing to configure at this time.

# ---------------------------------------------
# ---------- Functions ------------------------
# ---------------------------------------------

. /vagrant/assets/bash/funcs.bash;

# ---------------------------------------------
# ---------- Check Setup State ----------------
# ---------------------------------------------

if [[ -f /etc/vagrant/.wordpress-complete ]]; then
	exit 0; # Nothing more to do here.
fi; # End conditional check.

# ---------------------------------------------
# ---------- Run Setup Routines ---------------
# ---------------------------------------------

# Download and install the latest version of WordPress.

curl --location --output /tmp/wordpress-latest.zip http://wordpress.org/latest.zip;
unzip -qq -d /tmp/wordpress-latest /tmp/wordpress-latest.zip;

cp --force --recursive /tmp/wordpress-latest/wordpress/* /vagrant-htdocs;
cp --force /vagrant/assets/wordpress/.wp-config.php /vagrant-htdocs/wp-config.php;

rm -r /tmp/wordpress-latest && rm /tmp/wordpress-latest.zip;

# Create theme/plugin symlinks if possible.

for wp_dir in  '/vagrant-wordpress' \
					'/vagrant-jaswsinc-wordpress' \
					'/vagrant-websharks-wordpress' ; do

	# Create theme symlinks if possible.

	if [[ -d "$wp_dir"/themes ]]; then
		for dir in "$wp_dir"/themes/*; do
			if [[ -d "$dir"/"$(basename "$dir")" ]]; then
				ln --symbolic "$dir"/"$(basename "$dir")" /vagrant-htdocs/wp-content/themes/"$(basename "$dir")";
			elif [[ -d "$dir" ]]; then # Not in a nested sub-directory; i.e., this is the theme directory?
				ln --symbolic "$dir" /vagrant-htdocs/wp-content/themes/"$(basename "$dir")";
			fi;
		done;
	fi;
	# Create plugin symlinks if possible.

	if [[ -d "$wp_dir"/plugins ]]; then
		for dir in "$wp_dir"/plugins/*; do
			if [[ -d "$dir"/"$(basename "$dir")" ]]; then
				ln --symbolic "$dir"/"$(basename "$dir")" /vagrant-htdocs/wp-content/plugins/"$(basename "$dir")";
			elif [[ -d "$dir" ]]; then # Not in a nested sub-directory; i.e., this is the plugin directory?
				ln --symbolic "$dir" /vagrant-htdocs/wp-content/plugins/"$(basename "$dir")";
			fi;
		done;
	fi;

done; # End WordPress symlinks.

# Mark setup as being complete.

touch /etc/vagrant/.wordpress-complete;
