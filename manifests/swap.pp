class server::swap inherits server {
  if $swap_enabled and $swap_size < 1 {
    fail('server class requires `swap_size` parameter when `swap_enabled` is true')
  }

  $ensure = $swap_enabled ? {
    true    => 'present',
    default => 'absent',
  }

  file_line { "swap_fstab_line_${swap_filename}":
    ensure  => $ensure,
    line    => "${swap_filename} swap swap defaults 0 0",
    path    => "/etc/fstab",
    match   => "${swap_filename}",
  }

  if $ensure == 'present' {
    exec { 'create swap file':
      command => "/bin/dd if=/dev/zero of=${swap_filename} bs=1M count=${swap_size}",
      creates => $swap_filename,
    }
    exec { 'attach swap file':
      command => "/sbin/mkswap ${swap_filename} && /sbin/swapon ${swap_filename}",
      require => Exec['create swap file'],
      unless  => "/sbin/swapon -s | grep ${swap_filename}",
    }
  }
  elsif $ensure == 'absent' {
    exec { 'detach swap file':
      command => "/sbin/swapoff ${swap_filename}",
      onlyif  => "/sbin/swapon -s | grep ${swap_filename}",
    }
    file { $swap_filename:
      ensure  => absent,
      require => Exec['detach swap file'],
      backup => false
    }
  }
}
