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

  exec { 'rsyslog fqdn':
    command => "sed -i '1i \$PreserveFQDN on' /etc/rsyslog.conf",
    unless  => 'grep -c "\$PreserveFQDN on" /etc/rsyslog.conf',
    path    => ['/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/'],
    notify  => Service['rsyslog'],
  }

  file_line { 'rsyslog remote':
    path    => '/etc/rsyslog.conf',
    line    => "*.* @${remote_logs_host}:${remote_logs_port}",
    match   => '^\*\.\* +@[a-zA-Z0-9.]+:[0-9]+$',
    ensure  => $ensure,
    notify  => Service['rsyslog'],
  }
}
