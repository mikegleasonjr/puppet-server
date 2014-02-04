class server::params {
  $packages            = ['vim']
  $packages_ensure     = 'present'
  $apt_update_interval = 'daily'
  $timezone            = 'UTC'
  $remote_logs_enabled = false
  $remote_logs_host    = 'undef'
  $remote_logs_port    = 0
  $swap_enabled        = false
  $swap_filename       = '/mnt/managed_swap'
  $swap_size           = floor($::memorysize_mb + 0)
}
