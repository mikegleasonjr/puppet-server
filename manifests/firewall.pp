class server::firewall {
  package { 'sshguard':
    ensure => latest,
  }

  file { '/etc/default/sshguard':
    ensure => present,
    require => Package['sshguard'],
  }

  file_line { 'sshguard configuration':
    path    => '/etc/default/sshguard',
    line    => 'ENABLE_FIREWALL=0',
    match   => '^ENABLE_FIREWALL=[01]$',
    ensure  => present,
    require => File['/etc/default/sshguard'],
  }

  resources { 'firewall':
    purge => true,
  }

  include server::firewall::pre
  include server::firewall::post
  include server::firewall::defaultrules

  class { '::firewall':
    before  => Class['server::firewall::post'],
    require => Class['server::firewall::pre'],
  }
}
