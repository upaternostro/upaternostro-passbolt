class passbolt::params {
  $mail = 'passbolt@example.com'
  $salt = 'DYhG93b0qyJfIxfs2guVoUubWwvniR2G0FgaC9mi'
  $cipherSeed = '76859309657453542496749683645'
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
       $php5_json_package_name      = 'php5-json'
       $php5_readline_package_name  = 'php5-readline'
       $php5_mysqlnd_package_name   = 'php5-mysqlnd'
       $php5_gd_package_name        = 'php5-gd'
       $php5_pear_package_name      = 'php-pear'
       $php5_dev_package_name       = 'php5-dev'
       $make_package_name           = 'make'
       $libgpgme11_dev_package_name = 'libgpgme11-dev'
       $git_package_name            = 'git'
       $home_dir                    = '/var/www'
       $path_to_repo                = "$home_dir/passbolt"
       $additional_packages         = $::operatingsystemmajrelease ? {
         '8'     => [ 'php5-gnupg', ],
         default => [],
      }
    }
    default: {
       warning("OS ${::osfamily} not supported.")
    }
  }

  $package_ensure      = 'latest'
  $package_name        = 'passbolt'
}
