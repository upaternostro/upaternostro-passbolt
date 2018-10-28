class passbolt::params {
  $mail = 'passbolt@example.com'
  $fullBaseUrl = 'https://passbolt.dev'
  $host = 'localhost'
  $login = 'user'
  $password = 'password'
  $database = 'database_name'
  $fingerprint = '2FC8945833C51946E937F9FED47B0811573EE67E'
  $publicKeyName = 'serverkey.asc'
  $privateKeyName = 'serverkey.private.asc'
  $forceSSL = true
  $smtpServer = 'smtp.mandrillapp.com'
  $port = 587
  $smtpUser = undef
  $smtpPassword = undef
  $setenv = false

  case $::osfamily {
    'Debian': {
       $user                        = 'www-data'
       $group                       = 'www-data'
       $make_package_name           = 'make'
       $composer_package_name       = 'composer'
       $git_package_name            = 'git'
       $home_dir                    = '/var/www'
       $path_to_repo                = "$home_dir/passbolt"
       $php_pear_package_name       = 'php-pear'
       case $::operatingsystemmajrelease {
         '9': {
           $libgpgme_dev_package_name = 'libgpgme-dev'
           $php_json_package_name     = 'php-json'
           $php_readline_package_name = 'php-readline'
           $php_mysqlnd_package_name  = 'php-mysql'
           $php_gd_package_name       = 'php-gd'
           $php_dev_package_name      = 'php-dev'
           $additional_packages       = [ 'php-gnupg', ]
           $php_so_dir                = '/usr/lib/php/20151012'
           $php_timezone_conf         = '/etc/php/7.0/apache2/conf.d/00-timezone.ini'
           $php_gnupg_conf            = '/etc/php/7.0/apache2/conf.d/20-gnupg.ini'
         }
         '8': {
           $libgpgme_dev_package_name = 'libgpgme11-dev'
           $php_json_package_name     = 'php5-json'
           $php_readline_package_name = 'php5-readline'
           $php_mysqlnd_package_name  = 'php5-mysqlnd'
           $php_gd_package_name       = 'php5-gd'
           $php_dev_package_name      = 'php5-dev'
           $additional_packages       = [ 'php5-gnupg', ]
           $php_so_dir                = '/usr/lib/php5/20100525+lfs'
           $php_timezone_conf         = '/etc/php5/conf.d/00-timezone.ini'
           $php_gnupg_conf            = '/etc/php5/conf.d/50-gnupg.ini'
         }
         default: {
           $libgpgme_dev_package_name = 'libgpgme11-dev'
           $php_json_package_name     = 'php5-json'
           $php_readline_package_name = 'php5-readline'
           $php_mysqlnd_package_name  = 'php5-mysqlnd'
           $php_gd_package_name       = 'php5-gd'
           $php_dev_package_name      = 'php5-dev'
           $additional_packages       = []
           $php_so_dir                = '/usr/lib/php5/20100525+lfs'
           $php_timezone_conf         = '/etc/php5/conf.d/00-timezone.ini'
           $php_gnupg_conf            = '/etc/php5/conf.d/50-gnupg.ini'
         }
       }
    }
    default: {
       warning("OS ${::osfamily} not supported.")
    }
  }

  $package_ensure      = 'latest'
  $package_name        = 'passbolt'
}
