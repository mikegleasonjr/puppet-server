#server

####Table of Contents

1. [Overview - What is the Server module?](#overview)
2. [Module Description - What does the module do?](#module-description)
3. [Setup - The basics of getting started with Server](#setup)
    * [What Server affects](#what-server-affects)
    * [Setup Requirements](#setup-requirements)
    * [Beginning with Server](#beginning-with-server)
4. [Usage - Configuration and customization options](#usage)
    * [Packages installed - Setting up the default packages that should be present on your servers](#packages-installed)
    * [Package list index update - Setting up the package list index update frequency](#package-list-index-update)
    * [Timezone - Setting up the server's timezone](#timezone)
    * [Remote logging - Sending logs to another host](#remote-logging)
    * [Swap file - Setting up a swap file](#swap-file)
    * [Firewall - Understanding how the firewall is set up](#firewall)
6. [Limitations - OS compatibility, etc.](#limitations)

##Overview

The Server module serves as a base configuration for all your managed servers.

##Module Description

Server introduces the class `server`, which is used to put the server in a secure and valid state before managing anything else. Even if your server pool contains many different types of servers, the `server` class can be used to manage the common resources that has to be present on all of them.

##Setup

###What Server affects:

* packages installed
* firewall settings
* rsyslog settings
* swap files
* server's timezone and time synchronization

###Setup Requirements

Server uses the module [puppetlabs/firewall](https://github.com/puppetlabs/puppetlabs-firewall) which uses Ruby-based providers, so you must have [pluginsync enabled](http://docs.puppetlabs.com/guides/plugins_in_modules.html#enabling-pluginsync).

###Beginning with Server

    class { 'server': }

This will:

* install `vim`
* update the package list index every day
* open up port 22 and protect it from brute force attacks, while blocking everything else
* will set the timezone to `UTC`
* synchronize the time with `ntp`

##Usage

You can change the default behavior with the following options:

###Packages installed

You can make sure that certain packages are installed and automatically updated. Defaults to `vim` and `present`.

    class { 'server':
      packages        => ['vim', 'htop', 'tree'],
      packages_ensure => 'latest',
    }

###Package list index update

You can control the package list index update frequency. Defaults to `daily`.

    class { 'server':
      apt_update_interval => 'weekly',
    }

###Timezone

You can change the server's timezone. Defaults to `UTC`.

    class { 'server':
      timezone => 'America/New_York',
    }

###Remote logging

You can change configure `rsyslog` to send the logs on a remote machine or service like [papertrail](http://papertrailapp.com/). Defaults to disabled.

    class { 'server':
      remote_logs_enabled => true,
      remote_logs_host    => 'logs.papertrailapp.com',
      remote_logs_port    => 123,
    }

###Swap file

Lets you can create and enable a swap file on the server. Defaults to no swap file. Current swap files not managed by `server` will be preserved.

    class { 'server':
      swap_enabled => true,
    }

This will create the swap `/mnt/managed_swap` with a size equivalent of the amount of RAM installed. You can also change the swap location and size:

    class { 'server':
      swap_enabled  => true,
      swap_filename => '/mnt/swap1',
      swap_size     => 1024
    }

###Firewall

The module uses:

- [puppetlabs/firewall](https://github.com/puppetlabs/puppetlabs-firewall) to set up the firewall
- [sshguard](http://www.sshguard.net/) to block brute force attacks on port 22

Any unknown firewall rules are flushed so you need to use the puppetlabs/firewall module to set up additional configurations:

    class { 'server': }

    firewall { '100 allow http and https access':
        port   => [80, 443],
        proto  => tcp,
        action => accept,
    }

You can also prevent brute force attacks on additional ports (other than 22).

Here's an example of brute force attack prevention on port 8140:

    class { 'server': }

    firewall { '003 forward 8140 to sshguard':
        chain => 'INPUT',
        dport => 8140,
        proto => 'tcp',
        jump  => 'sshguard',
    }

    firewall { '001 allow 8140 access in sshguard':
        chain  => 'sshguard',
        action => 'accept',
        proto  => 'tcp',
        dport  => 8140,
    }

sshguard will automatically insert blocking rules to offending IPs at the beginning of the `sshguard` chain.

##Limitations

This module has been tested on

* Ubuntu 12.04
* Debian 6

Bugs can be reported using Github Issues:

<https://github.com/mikegleasonjr/puppet-server/issues>
