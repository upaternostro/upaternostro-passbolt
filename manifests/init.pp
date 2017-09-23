# == Class: passbolt
#
# Full description of class passbolt here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { 'passbolt':
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2017 Your name here, unless otherwise noted.
#
# === Based on
#
# https://medium.com/passbolt/passbolt-on-debian-8-71-from-scratch-4438dad18908
#
class passbolt (
  $home_dir       = $passbolt::params::home_dir,
  $path_to_repo   = $passbolt::params::path_to_repo,
  $package_ensure = $passbolt::params::package_ensure,
  $package_name   = $passbolt::params::package_name,
  $user           = $passbolt::params::user,
  $group          = $passbolt::params::group,
  $mail           = $passbolt::params::mail,
  $salt           = $passbolt::params::salt,
  $cipherSeed     = $passbolt::params::cipherSeed,
  $fullBaseUrl    = $passbolt::params::fullBaseUrl,
  $host           = $passbolt::params::host,
  $login          = $passbolt::params::login,
  $password       = $passbolt::params::password,
  $database       = $passbolt::params::database,
  $fingerprint    = $passbolt::params::fingerprint,
  $publicKeyName  = $passbolt::params::publicKeyName,
  $privateKeyName = $passbolt::params::privateKeyName,
  $forceSSL       = $passbolt::params::forceSSL,
  $smtpServer     = $passbolt::params::smtpServer,
  $port           = $passbolt::params::port,
  $smtpUser       = $passbolt::params::smtpUser,
  $smtpPassword   = $passbolt::params::smtpPassword,
  $setenv         = $passbolt::params::setenv,
) inherits passbolt::params {
  include apache
  include apache::mod::php
  include apache::mod::rewrite
#  include apache::mod::ssl
  include apache::mod::headers

  class { '::passbolt::install':
    package_ensure => $package_ensure,
    package_name   => $package_name,
    path_to_repo   => $path_to_repo,
    user           => $user,
    group          => $group,
    mail           => $mail,
  } -> file { 'core.php':
    path => "$path_to_repo/app/Config/core.php",
    owner  => "$user",
    group  => "$group",
    content => template('passbolt/core.php.erb'),
  } -> file { 'database.php':
    path => "$path_to_repo/app/Config/database.php",
    owner  => "$user",
    group  => "$group",
    content => template('passbolt/database.php.erb'),
  } -> file { 'app.php':
    path => "$path_to_repo/app/Config/app.php",
    owner  => "$user",
    group  => "$group",
    content => template('passbolt/app.php.erb'),
  } -> file { 'email.php':
    path => "$path_to_repo/app/Config/email.php",
    owner  => "$user",
    group  => "$group",
    content => template('passbolt/email.php.erb'),
  } -> cron { 'EmailQueue.sender':
    command  => "$path_to_repo/app/Console/cake EmailQueue.sender > $path_to_repo/app/tmp/email.log",
    user     => "$user",
    hour     => '*',
    minute   => '*',
    month    => '*',
    monthday => '*',
    weekday  => '*',
  }
}
