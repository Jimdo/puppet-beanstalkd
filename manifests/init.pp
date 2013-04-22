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
#  $binlog_dir:: Use a binlog to keep jobs on persistent storage in <dir>.
#                Upon startup, beanstalkd will recover any binlog that is
#                present in <dir>, then, during normal operation, append new
#                jobs and changes in state to the binlog.
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
#    binlog_dir => '/var/lib/beanstalkd/binlog'
#  }
#
class beanstalkd(
  $listen_addr      = '127.0.0.1',
  $listen_port      = '11300',
  $start_service    = false,
  $binlog_dir       = undef,
  $binlog_max_size  = undef,
  $fsync_max        = undef,
  $job_max_size     = undef
) {

  case $::operatingsystem {
    debian, default: {
      $config_file      = '/etc/default/beanstalkd'
      $config_template  = 'config.debian.erb'
      $beanstalkd_user  = 'beanstalkd'
    }
  }

  package { 'beanstalkd':
    ensure => installed,
  }

  file { 'beanstalkd_config':
    ensure    => present,
    path      => $config_file,
    content   => template("beanstalkd/${config_template}"),
    notify    => Service[beanstalkd]
  }

  service { 'beanstalkd':
    ensure    => $start_service ? {
      false => 'stopped',
      true  => 'running'
    }
  }

  Package['beanstalkd'] -> File['beanstalkd_config']

  if $binlog_dir {
    exec { 'beanstalkd_binlog_dir' :
      command => "/usr/bin/install -o${beanstalkd_user} -m0755 -d '${binlog_dir}'",
      creates => $binlog_dir,
      logoutput => true
    }

    file { 'beanstalkd_binlog_dir' :
      ensure => directory,
      path => $binlog_dir,
      mode => 0755
    }

    Package['beanstalkd'] -> Exec['beanstalkd_binlog_dir']
    Exec['beanstalkd_binlog_dir'] -> File['beanstalkd_binlog_dir']
    File['beanstalkd_binlog_dir'] -> File['beanstalkd_config']
  }

  File['beanstalkd_config'] -> Service['beanstalkd']
}
