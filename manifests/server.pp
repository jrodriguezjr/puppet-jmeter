# == Class: jmeter::server
#
# This class configures the server component of JMeter.
#
# === Examples
#
#   class { 'jmeter::server': }
#
class jmeter::server (
  $server_ip = '0.0.0.0',
  $jmeter_version         = '2.11',
  $jmeter_plugins_install = True,
  $jmeter_plugins_version = '1.1.3',
) {

  class { 'jmeter':
    jmeter_version         => $jmeter_version,
    jmeter_plugins_install => $jmeter_plugins_install,
    jmeter_plugins_version => $jmeter_plugins_version,
  }

  $init_template = $::osfamily ? {
    debian => 'jmeter/jmeter-init.erb',
    redhat => 'jmeter/jmeter-init.redhat.erb'
  }

  file { '/etc/init.d/jmeter':
    content => template($init_template),
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
  }

  if $::osfamily == 'debian' {
    exec { 'jmeter-update-rc':
      command     => '/usr/sbin/update-rc.d jmeter defaults',
      subscribe   => File['/etc/init.d/jmeter'],
      refreshonly => true,
    }
  }

  service { 'jmeter':
    ensure    => running,
    enable    => true,
    require   => File['/etc/init.d/jmeter'],
    subscribe => [File['/etc/init.d/jmeter'], Exec['install-jmeter-plugins']],
  }
}
