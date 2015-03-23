<?php
ini_set('session.save_path', '/tmp');
ini_set('session.gc_maxlifetime', 86400);
$cfg['LoginCookieValidity'] = 86400;

$cfg['blowfish_secret']       = $_SERVER['TOOLS_PMA_BLOWFISH_KEY'];
$cfg['Servers'][1]['host']    = 'localhost';
$cfg['Servers'][1]['port']    = '3306';
$cfg['Servers'][1]['hide_db'] = '(?:(?:performance|information)_schema|phpmyadmin|mysql|innodb)';
$cfg['PmaAbsoluteUri']        = 'https://'.$_SERVER['HTTP_HOST'].'/tools/pma/';
