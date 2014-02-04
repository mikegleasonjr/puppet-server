class server::firewall::defaultrules {
  firewallchain { 'sshguard:filter:IPv4':
    ensure => present,
  }

  firewall { '003 forward ssh to sshguard':
    chain => 'INPUT',
    dport => 22,
    proto => 'tcp',
    jump  => 'sshguard',
  }

  firewall { '001 allow ssh access in sshguard':
    chain  => 'sshguard',
    action => 'accept',
    proto  => 'tcp',
    dport  => 22,
  }
}
