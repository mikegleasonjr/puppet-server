class server(
  $packages            = $server::params::packages,
  $packages_ensure     = $server::params::packages_ensure,
  $apt_update_interval = $server::params::apt_update_interval,
  $timezone            = $server::params::timezone,
  $remote_logs_enabled = $server::params::remote_logs_enabled,
  $remote_logs_host    = $server::params::remote_logs_host,
  $remote_logs_port    = $server::params::remote_logs_port,
  $swap_enabled        = $server::params::swap_enabled,
  $swap_filename       = $server::params::swap_filename,
  $swap_size           = $server::params::swap_size
) inherits server::params {
  validate_array($packages)
  validate_string($packages_ensure)
  validate_string($apt_update_interval)
  validate_string($timezone)
  validate_bool($remote_logs_enabled)
  validate_string($remote_logs_host)
  if ! is_integer($remote_logs_port) { fail('`remote_logs_port` must be an integer') }
  validate_bool($swap_enabled)
  validate_absolute_path($swap_filename)
  if ! is_integer($swap_size) { fail('`swap_size` must be an integer') }

  include server::packages
  include server::firewall
  include server::time
  include server::logs
  include server::swap
}
