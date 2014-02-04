class server::logs inherits server {
  if $remote_logs_enabled and (! is_domain_name($remote_logs_host) or $remote_logs_port < 1) {
    fail('server class requires parameters `remote_logs_host` and `remote_logs_port` when `remote_logs_enabled` is true')
  }

  $ensure = $remote_logs_enabled ? {
    true    => 'present',
    default => 'absent',
  }

  service { 'rsyslog':
    ensure     => running,
    enable     => true,
    hasrestart => true,
  }

  File_line {
    path   => '/etc/rsyslog.conf',
    ensure => $ensure,
    notify => Service['rsyslog'],
  }

  file_line { 'rsyslog hostname':
    line   => "\$LocalHostName ${fqdn}",
    match  => '^\$LocalHostName +[a-zA-Z0-9.-]+$',
  }

  file_line { 'rsyslog remote':
    line    => "*.* @${remote_logs_host}:${remote_logs_port}",
    match   => '^\*\.\* +@[a-zA-Z0-9.]+:[0-9]+$',
    require => File_line['rsyslog hostname'],
  }
}
