class server::packages inherits server {
  schedule { 'apt_update_interval':
    period => $apt_update_interval,
  }

  exec { '/usr/bin/apt-get update':
    schedule => 'apt_update_interval',
  }

  package { $packages:
    ensure => $packages_ensure,
  }
}
