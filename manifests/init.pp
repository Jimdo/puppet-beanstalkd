################################################################################
# Class: beanstalkd
#
# This module manages the beanstalkd service.
#
# Parameters:
#
#  $listen_addr:: Listen on address <addr> (default is 127.0.0.1)
#  $listen_port:: Listen on TCP port <port> (default is 11300).
#  $start_service:: true/false. (default is false)
#  $binlog:: Use a binlog to keep jobs on persistent storage in
#            '/var/lib/beanstalkd' Upon startup, beanstalkd will recover any
#            binlog that is present in <dir>, then, during normal operation,
#            append new jobs and changes in state to the binlog.
#  $binlog_max_size:: The maximum size in bytes of each binlog file.
#  $fsync_max:: Call fsync(2) at most once every <ms> milliseconds.
#               This will recuce disk activity and improve speed at the
#               cost of safety. A power failure could result in the loss of
#               up to <ms> milliseconds of history. A <ms> value of 0 will
#               cause beanstalkd to call fsync every time it writes to
#               the binlog.
#  $job_max_size:: The maximum size in bytes of a job.
#
# Sample Usage:
#
#  class { 'beanstalkd':
#    listen_addr => '1.2.3.4',
#    listen_port => 12345,
#    binlog      => true,
#  }
#
class beanstalkd(
  $listen_addr      = '127.0.0.1',
  $listen_port      = '11300',
  $start_service    = false,
  $binlog           = false,
  $binlog_max_size  = undef,
  $fsync_max        = undef,
  $job_max_size     = undef
) {

  case $::operatingsystem {
    debian: {
      $config_file      = '/etc/default/beanstalkd'
      $config_template  = 'config.debian.erb'
      $user             = 'beanstalkd'
      $package_name     = 'beanstalkd'
      $binlog_dir       = '/var/lib/beanstalkd'
    }
    default: {
      fail("Module beanstalkd is not supported on ${::operatingsystem}")
    }
  }

  package { 'beanstalkd':
    ensure => 'installed',
    name   => $package_name,
  }

  file { $config_file :
    ensure    => 'present',
    path      => $config_file,
    content   => template("beanstalkd/${config_template}"),
    notify    => Service['beanstalkd'],
  }

  $service_state = $start_service ? {
    false => 'stopped',
    true  => 'running',
  }

  service { 'beanstalkd':
    ensure => $service_state,
  }

  Package['beanstalkd'] -> File[$config_file]

  if $binlog {
    exec { 'beanstalkd_binlog_dir' :
      command   => "/usr/bin/install -o${user} -m0755 -d '${binlog_dir}'",
      creates   => $binlog_dir,
      logoutput => true,
    }

    file { $binlog_dir :
      ensure => 'directory',
      path   => $binlog_dir,
      owner  => $user,
      group  => $user,
      mode   => '0755',
    }

    Package['beanstalkd'] -> Exec['beanstalkd_binlog_dir']
    Exec['beanstalkd_binlog_dir'] -> File[$binlog_dir]
    File[$binlog_dir] -> File[$config_file]
  }

  File[$config_file] -> Service['beanstalkd']
}
