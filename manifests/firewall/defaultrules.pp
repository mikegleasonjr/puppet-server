class server::firewall::defaultrules {
  firewallchain {[
      'INPUT:filter:IPv4',
      'FORWARD:filter:IPv4',
      'OUTPUT:filter:IPv4',
      'PREROUTING:raw:IPv4',
      'OUTPUT:raw:IPv4',
    ]:
    ensure => present,
    purge  => true,
  }

  firewallchain { 'sshguard:filter:IPv4':
    ensure => present,
    purge  => false,
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
