<?php
error_reporting(-1);
ini_set('display_errors', 'yes');

header('content-type: text/plain; charset=utf-8');
print_r(opcache_get_status());
