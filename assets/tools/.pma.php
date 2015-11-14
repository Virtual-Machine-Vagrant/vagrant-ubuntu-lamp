<?php
ini_set('session.save_path', '/tmp');
ini_set('session.gc_maxlifetime', '86400');
$cfg['LoginCookieValidity'] = 86400;

$cfg['Servers'][1]['host'] = $_SERVER['MYSQL_DB_HOST'];
$cfg['Servers'][1]['port'] = $_SERVER['MYSQL_DB_PORT'];

#$cfg['Servers'][1]['ssl']         = true;
#$cfg['Servers'][1]['ssl_key']     = '/etc/bootstrap/ssl/client.key';
#$cfg['Servers'][1]['ssl_cert']    = '/etc/bootstrap/ssl/client.crt';
#$cfg['Servers'][1]['ssl_ca']      = '/bootstrap/assets/ssl/ca.vm.crt';

$cfg['blowfish_secret']       = $_SERVER['TOOLS_PMA_BLOWFISH_KEY'];
$cfg['Servers'][1]['hide_db'] = '(?:(?:performance|information)_schema|phpmyadmin|mysql|innodb)';

$cfg['PmaAbsoluteUri'] = 'https://'.$_SERVER['HTTP_HOST'].'/tools/pma/';
$cfg['ForceSSL']       = true;
