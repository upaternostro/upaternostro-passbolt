class passbolt::install (
  $package_ensure = present,
  $package_name = 'passbolt',
  $path_to_repo,
  $user = 'www-data',
  $group = 'www-data',
  $mail = 'passbolt@example.com'
) inherits passbolt {

  package { 'php5-json':
    ensure => $package_ensure,
    name   => $php5_json_package_name,
  }

  apt::key { 'dotdeb':
    id      => '6572BBEF1B5FF28B28B706837E3F070089DF5277',
    source  => 'https://www.dotdeb.org/dotdeb.gpg',
  } -> apt::source { 'dotdeb':
    location => 'http://packages.dotdeb.org',
    repos    => 'all',
  } -> package { 'php5-readline':
    ensure  => $package_ensure,
    name    => $php5_readline_package_name,
  }

  package { 'php5-mysqlnd':
    ensure => $package_ensure,
    name   => $php5_mysqlnd_package_name,
  }

  package { 'php5-gd':
    ensure => $package_ensure,
    name   => $php5_gd_package_name,
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
  } -> file { "$path_to_repo/app/Config":
    ensure => directory,
    owner  => "$user",
    group  => "$group",
  } -> file { "$path_to_repo/app/tmp":
    ensure  => directory,
    group   => "$group",
    mode    => "2775",
    recurse => true,
  } -> file { "$path_to_repo/app/webroot/img/public":
    ensure => directory,
    group  => "$group",
    mode   => "2775",
  } -> package { 'libgpgme11-dev':
    ensure => $package_ensure,
    name   => $libgpgme11_dev_package_name,
  } -> package { 'php5-dev':
    ensure => $package_ensure,
    name   => $php5_dev_package_name,
  } -> package { 'php5-pear':
    ensure => $package_ensure,
    name   => $php5_pear_package_name,
  } -> package { 'make':
    ensure => $package_ensure,
    name   => $make_package_name,
  } -> exec { 'pecl install gnupg':
    timeout => 0,
    creates => '/usr/lib/php5/20100525+lfs/gnupg.so',
    path    => ['/bin', '/sbin', '/usr/bin', '/usr/sbin',],
  } -> file { '/etc/php5/conf.d/00-timezone.ini':
    content => 'date.timezone = Europe/Rome',
    notify  => Service[httpd],
  } -> file { '/etc/php5/conf.d/50-gnupg.ini':
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
    creates => "$path_to_repo/app/Config/gpg/$privateKeyName",
    path    => ['/bin', '/sbin', '/usr/bin', '/usr/sbin',],
  } -> exec { 'gnupg --export':
    command => "gpg --homedir $home_dir/.gnupg --armor --export $mail > $path_to_repo/app/Config/gpg/$publicKeyName",
    creates => "$path_to_repo/app/Config/gpg/$publicKeyName",
    path    => ['/bin', '/sbin', '/usr/bin', '/usr/sbin',],
  }
}
