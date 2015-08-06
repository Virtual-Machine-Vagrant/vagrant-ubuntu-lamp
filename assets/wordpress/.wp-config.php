<?php
define('WP_ALLOW_MULTISITE', true);

/**
 * The base configurations of the WordPress.
 *
 * This file has the following configurations: MySQL settings, Table Prefix,
 * Secret Keys, and ABSPATH. You can find more information by visiting
 * {@link http://codex.wordpress.org/Editing_wp-config.php Editing wp-config.php}
 * Codex page. You can get the MySQL settings from your web host.
 *
 * This file is used by the wp-config.php creation script during the
 * installation. You don't have to use the web site, you can just copy this file
 * to "wp-config.php" and fill in the values.
 *
 * @package WordPress
 */

// ** MySQL settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define('DB_NAME', $_SERVER['MYSQL_DB_NAME']);

/** MySQL database username */
define('DB_USER', $_SERVER['MYSQL_DB_USER']);

/** MySQL database password */
define('DB_PASSWORD', $_SERVER['MYSQL_DB_PASSWORD']);

/** MySQL hostname */
define('DB_HOST', $_SERVER['MYSQL_DB_HOST']);

/** Database Charset to use in creating database tables. */
define('DB_CHARSET', 'utf8');

/** The Database Collate type. Don't change this if in doubt. */
define('DB_COLLATE', '');

/**#@+
 * Authentication Unique Keys and Salts.
 *
 * Change these to different unique phrases!
 * You can generate these using the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}
 * You can change these at any point in time to invalidate all existing cookies. This will force all users to have to log in again.
 *
 * @since 2.6.0
 */
define('AUTH_KEY',         'vdkU)Jj/heyZh#+BDtd@(@yJ&g DLZ}!dFZPh2#u{9~_0+5,4J([+#[f0T@7,V2A');
define('SECURE_AUTH_KEY',  'A<n2wKOv0Lh--GUi?mvDi[E+u^NePc-r]fQ.%8vu+XDToRfvB8Cg+<W1|>A`z1{W');
define('LOGGED_IN_KEY',    '&iL]oO#lVwWW`R6x%VUP-KdB44Y~Gn+BUX#JY2d1|c$fh=_,bR%}~kYp)>|vCUOR');
define('NONCE_KEY',        'Gn{N)EHG7S:z4aqzi~A4?et1aW5SA[Zlgn2YWU30c5*GuSuO0z/o2;k.w(o?t%vK');
define('AUTH_SALT',        'sZ1b|Snm8rRaKf@MI&aiG-qdI:vI`_x3L-s<g{G~=$mAWtaYT..:?[Pw]gQ-`3-0');
define('SECURE_AUTH_SALT', 'bH?k:FM$+3{$9/9<FbhHpP~Okk!`K)(F*&AVM]00T< hwkVgU=$vC_3i~{c/+ lT');
define('LOGGED_IN_SALT',   'NS5d%U!7gl n)VZh^BB<{;M1smapyUv#k`z|Mc*jZZA}]cCVIr$Q*mX)k@q`h5,$');
define('NONCE_SALT',       'c>+ [o|0<G*_Wz|.ObGHm)Xy[U 6Rt#e<{6BxKW)2aZ72d`ns8Zloa&Gchen.$/k');

/**#@-*/

/**
 * WordPress Database Table prefix.
 *
 * You can have multiple installations in one database if you give each a unique
 * prefix. Only numbers, letters, and underscores please!
 */
$table_prefix  = 'wp_';

/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 */
define('WP_DEBUG', true);
define('WP_DEBUG_LOG', true);
define('WP_DEBUG_DISPLAY', true);

/* That's all, stop editing! Happy blogging. */

/** Absolute path to the WordPress directory. */
if ( !defined('ABSPATH') )
	define('ABSPATH', dirname(__FILE__) . '/');

/** Sets up WordPress vars and included files. */
require_once(ABSPATH . 'wp-settings.php');
