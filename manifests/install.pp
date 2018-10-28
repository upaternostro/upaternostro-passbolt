class passbolt::install (
  $package_ensure = present,
  $package_name = 'passbolt',
  $path_to_repo,
  $user = 'www-data',
  $group = 'www-data',
  $mail = 'passbolt@example.com'
) inherits passbolt {

  package { 'php-json':
    ensure => $package_ensure,
    name   => $php_json_package_name,
  }

  each($additional_packages) |$pkg| {
    package { "$pkg":
      ensure => $package_ensure,
    }
  }

  if $facts['osfamily'] == 'Debian' and $facts['operatingsystemmajrelease'] < '9' {
    apt::key { 'dotdeb':
      id      => '6572BBEF1B5FF28B28B706837E3F070089DF5277',
      source  => 'https://www.dotdeb.org/dotdeb.gpg',
    } -> apt::source { 'dotdeb':
      location => 'http://packages.dotdeb.org',
      repos    => 'all',
    } -> package { 'php-readline':
      ensure  => $package_ensure,
      name    => $php_readline_package_name,
    }
  } else {
    package { 'php-readline':
      ensure  => $package_ensure,
      name    => $php_readline_package_name,
    }
  }

  package { 'php-mysqlnd':
    ensure => $package_ensure,
    name   => $php_mysqlnd_package_name,
  }

  package { 'php-gd':
    ensure => $package_ensure,
    name   => $php_gd_package_name,
  }

  package { 'git':
    ensure => $package_ensure,
    name   => $git_package_name,
  } -> vcsrepo { $path_to_repo:
    ensure   => present,
    provider => git,
    source   => 'https://github.com/passbolt/passbolt_api.git',
  } -> file { "$path_to_repo/.gitmodules":
    content => '[submodule "cakephp-html-purifier"]
                path = app/Vendor/burzum/cakephp-html-purifier
                url = https://github.com/burzum/cakephp-html-purifier'
  } -> exec { 'git submodule init':
    cwd     => "$path_to_repo",
    path    => ['/bin', '/sbin', '/usr/bin', '/usr/sbin',],
  } -> exec { 'git submodule update':
    cwd     => "$path_to_repo",
    creates => "$path_to_repo/app/Vendor/burzum/cakephp-html-purifier/.git",
    path    => ['/bin', '/sbin', '/usr/bin', '/usr/sbin',],
  } -> file { "$path_to_repo/config":
    ensure => directory,
    owner  => "$user",
    group  => "$group",
  } -> file { "$path_to_repo/tmp":
    ensure  => directory,
    group   => "$group",
    mode    => "2775",
    recurse => true,
  } -> file { "$path_to_repo/webroot/img/public/images":
    ensure => directory,
    group  => "$group",
    mode   => "2775",
  } -> package { 'libgpgme-dev':
    ensure => $package_ensure,
    name   => $libgpgme_dev_package_name,
  } -> package { 'php-dev':
    ensure => $package_ensure,
    name   => $php_dev_package_name,
  } -> package { 'php-pear':
    ensure => $package_ensure,
    name   => $php_pear_package_name,
  } -> package { 'make':
    ensure => $package_ensure,
    name   => $make_package_name,
  } -> package { 'composer':
    ensure => $package_ensure,
    name   => $composer_package_name,
  } -> exec { 'pecl install gnupg':
    timeout => 0,
    creates => "${php_so_dir}/gnupg.so",
    path    => ['/bin', '/sbin', '/usr/bin', '/usr/sbin',],
  } -> exec { 'composer install --no-dev':
    timeout => 0,
    creates => "${path_to_repo}/vendor",
    path    => ['/bin', '/sbin', '/usr/bin', '/usr/sbin',],
  } -> file { "$php_timezone_conf":
    content => 'date.timezone = Europe/Rome',
    notify  => Service[httpd],
  } -> file { "$php_gnupg_conf":
    content => 'extension=gnupg.so',
    notify  => Service[httpd],
  } -> file { "$home_dir/.gnupg":
    ensure => directory,
    owner  => "$user",
    group  => "$group",
  } -> exec { 'gnupg --gen-key':
    command => "cat << EOF | gpg --gen-key --batch
Key-Type: RSA
Key-Length: 4096
Name-Real: Passbolt server
Name-Email: $mail
Expire-Date: 0
%commit
EOF",
    user    => "$user",
    timeout => 0,
    creates => "$home_dir/.gnupg/secring.gpg",
    path    => ['/bin', '/sbin', '/usr/bin', '/usr/sbin',],
  } -> exec { 'gnupg --export-secret-keys':
    command => "gpg --homedir $home_dir/.gnupg --armor --export-secret-keys $mail > $path_to_repo/app/Config/gpg/$privateKeyName",
    creates => "$path_to_repo/config/gpg/$privateKeyName",
    path    => ['/bin', '/sbin', '/usr/bin', '/usr/sbin',],
  } -> exec { 'gnupg --export':
    command => "gpg --homedir $home_dir/.gnupg --armor --export $mail > $path_to_repo/app/Config/gpg/$publicKeyName",
    creates => "$path_to_repo/config/gpg/$publicKeyName",
    path    => ['/bin', '/sbin', '/usr/bin', '/usr/sbin',],
  }
}
