require 'spec_helper'

describe 'server', :type => :class do
  let(:node) { 'host.domain.com' }
  let(:facts) {{
    :kernel => 'Linux',
    :osfamily => 'Debian',
    :memorysize_mb => '1432.23'
  }}

  it { should contain_class('server::packages') }
  it { should contain_class('server::firewall') }
  it { should contain_class('server::time') }
  it { should contain_class('server::logs') }
  it { should contain_class('server::swap') }

  describe 'server::packages' do
    describe 'with default parameters' do
      it { should contain_package('vim').with_ensure('present') }
      it { should contain_schedule('apt_update_interval').with_period('daily') }
      it { should contain_exec('/usr/bin/apt-get update').with_schedule('apt_update_interval') }
    end

    context 'with custom parameters' do
      let(:params) { {
        :packages => ['git', 'htop'],
        :packages_ensure => 'latest',
        :apt_update_interval => 'weekly'
      } }

      it { should contain_package('git').with_ensure('latest') }
      it { should contain_package('htop').with_ensure('latest') }
      it { should contain_schedule('apt_update_interval').with_period('weekly') }
    end
  end

  describe 'server::firewall' do
    it { should contain_class('firewall').with(
      :before  => 'Class[Server::Firewall::Post]',
      :require => 'Class[Server::Firewall::Pre]'
    ) }

    it { should contain_resources('firewall').with(
      :purge => 'true'
    ) }

    it { should contain_firewall('001 accept all icmp').with(
      :proto => 'icmp',
      :action => 'accept',
      :require => nil
    ) }

    it { should contain_firewall('002 accept all to lo interface').with(
      :proto => 'all',
      :action => 'accept',
      :iniface => 'lo',
      :require => nil
    ) }

    it { should contain_firewall('001 do not track incoming packets to lo interface').with(
      :iniface => 'lo',
      :table   => 'raw',
      :chain   => 'PREROUTING',
      :proto   => 'tcp',
      :jump    => 'NOTRACK',
      :require => nil
    ) }

    it { should contain_firewall('001 do not track outgoing packets from lo interface').with(
      :outiface => 'lo',
      :table => 'raw',
      :chain => 'OUTPUT',
      :proto => 'tcp',
      :jump => 'NOTRACK',
      :require => nil
    ) }

    it { should contain_firewall('900 accept related established rules').with(
      :proto => 'all',
      :state => ['RELATED', 'ESTABLISHED'],
      :action => 'accept',
      :require => nil
    ) }

    it { should contain_firewall('999 drop all').with(
      :proto => 'all',
      :before => nil,
      :action => 'drop'
    ) }

    describe 'use sshguard for ssh connection attemps' do
      it { should contain_package('sshguard').with(
        :ensure => 'latest'
      ) }

      it { should contain_file_line('sshguard configuration').with(
        :path => '/etc/default/sshguard',
        :line => 'ENABLE_FIREWALL=0',
        :match => '^ENABLE_FIREWALL=[01]$',
        :ensure => 'present',
        :require => 'Package[sshguard]'
      ) }

      it { should contain_firewallchain('sshguard:filter:IPv4').with(
        :ensure => 'present'
      ) }

      it { should contain_firewall('003 forward ssh to sshguard').with(
        :chain => 'INPUT',
        :dport => 22,
        :proto => 'tcp',
        :jump => 'sshguard'
      ) }

      it { should contain_firewall('001 allow ssh access in sshguard').with(
        :chain => 'sshguard',
        :dport => 22,
        :proto => 'tcp',
        :action => 'accept'
      ) }
    end
  end

  describe 'server::time' do
    it { should contain_class('ntp').with_package_ensure('present') }
    it { should contain_class('timezone').with(
      :timezone => 'UTC',
      :autoupgrade => false
    ) }

    context 'with timezone => America/Montreal, package_ensure => latest' do
      let(:params) { {
          :timezone => 'America/Montreal',
          :packages_ensure => 'latest'
      } }

      it { should contain_class('ntp').with_package_ensure('latest') }
      it { should contain_class('timezone').with(
        :timezone => 'America/Montreal',
        :autoupgrade => true
      ) }
    end
  end

  describe 'server::logs' do
    it { should contain_service('rsyslog').with(
      :ensure => 'running',
      :enable => true,
      :hasrestart => true
    ) }

    it { should contain_file_line('rsyslog hostname').with(
      :path => '/etc/rsyslog.conf',
      :line => '$LocalHostName host.domain.com',
      :match => '^\$LocalHostName +[a-zA-Z0-9.-]+$',
      :notify => 'Service[rsyslog]',
      :ensure => 'absent'
    ) }

    it { should contain_file_line('rsyslog remote').with(
      :path => '/etc/rsyslog.conf',
      :line => '*.* @undef:0',
      :notify => 'Service[rsyslog]',
      :match => '^\*\.\* +@[a-zA-Z0-9.]+:[0-9]+$',
      :ensure => 'absent',
      :require => 'File_line[rsyslog hostname]'
    ) }

    context 'with remote_logs_enabled => true, remote_logs_host => logs.papertrailapp.com.test, remote_logs_port => 1234' do
      let(:params) { {
          :remote_logs_enabled => true,
          :remote_logs_host => 'logs.papertrailapp.com.test',
          :remote_logs_port => 1234
      } }

      it { should contain_file_line('rsyslog hostname').with(
        :path => '/etc/rsyslog.conf',
        :line => '$LocalHostName host.domain.com',
        :match => '^\$LocalHostName +[a-zA-Z0-9.-]+$',
        :notify => 'Service[rsyslog]',
        :ensure => 'present'
      ) }

      it { should contain_file_line('rsyslog remote').with(
        :path => '/etc/rsyslog.conf',
        :line => '*.* @logs.papertrailapp.com.test:1234',
        :notify => 'Service[rsyslog]',
        :match => '^\*\.\* +@[a-zA-Z0-9.]+:[0-9]+$',
        :ensure => 'present',
        :require => 'File_line[rsyslog hostname]'
      ) }
    end
  end

  describe 'server::swap' do
    it { should contain_file_line('swap_fstab_line_/mnt/managed_swap').with(
      :ensure  => 'absent',
      :line => '/mnt/managed_swap swap swap defaults 0 0',
      :path => '/etc/fstab',
      :match => '/mnt/managed_swap'
    ) }

    it { should contain_exec('detach swap file').with(
      :command => '/sbin/swapoff /mnt/managed_swap',
      :onlyif => '/sbin/swapon -s | grep /mnt/managed_swap'
    ) }

    it { should contain_file('/mnt/managed_swap').with(
      :ensure => 'absent',
      :backup => false,
      :require => 'Exec[detach swap file]'
    ) }

    context 'with swap_enabled => true, swap_filename => /mnt/swap' do
      let(:params) { {
        :swap_enabled => true,
        :swap_filename => '/mnt/swap',
      } }

      it { should contain_file_line('swap_fstab_line_/mnt/swap').with(
        :ensure  => 'present',
        :line => '/mnt/swap swap swap defaults 0 0',
        :path => '/etc/fstab',
        :match => '/mnt/swap'
      ) }

      it { should contain_exec('create swap file').with(
        :command => '/bin/dd if=/dev/zero of=/mnt/swap bs=1M count=1432',
        :creates => '/mnt/swap'
      ) }

      it { should contain_exec('attach swap file').with(
        :command => '/sbin/mkswap /mnt/swap && /sbin/swapon /mnt/swap',
        :require => 'Exec[create swap file]',
        :unless => '/sbin/swapon -s | grep /mnt/swap'
      ) }
    end
  end
end
