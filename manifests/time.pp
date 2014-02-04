class server::time inherits server {
  class { 'ntp':
    package_ensure => $packages_ensure,
  }

  class { 'timezone':
    timezone    => $timezone,
    autoupgrade => $packages_ensure == 'latest',
  }
}
