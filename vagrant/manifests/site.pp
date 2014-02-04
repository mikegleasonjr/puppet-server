class { 'server':
  packages            => ['vim', 'htop'],
  packages_ensure     => 'latest',
  apt_update_interval => 'hourly',
  timezone            => 'America/Montreal',
  remote_logs_enabled => true,
  remote_logs_host    => 'localhost',
  remote_logs_port    => 1234,
  swap_enabled        => true,
  swap_filename       => '/mnt/swap1',
  swap_size           => 50
}
