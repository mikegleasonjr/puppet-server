class server::firewall::pre {
  firewall { '001 accept all icmp':
    proto  => 'icmp',
    action => 'accept',
    require => undef,
  }

  firewall { '002 accept all to lo interface':
    proto   => 'all',
    iniface => 'lo',
    action  => 'accept',
    require => undef,
  }

  firewall { '001 do not track incoming packets to lo interface':
    iniface => 'lo',
    table   => 'raw',
    chain   => 'PREROUTING',
    proto   => 'tcp',
    jump    => 'NOTRACK',
    require => undef,
  }

  firewall { '001 do not track outgoing packets from lo interface':
    outiface => 'lo',
    table    => 'raw',
    chain    => 'OUTPUT',
    proto    => 'tcp',
    jump     => 'NOTRACK',
    require => undef,
  }

  firewall { '900 accept related established rules':
    proto  => 'all',
    state  => ['RELATED', 'ESTABLISHED'],
    action => 'accept',
    require => undef,
  }
}
