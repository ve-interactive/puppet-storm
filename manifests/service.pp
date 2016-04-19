# Define: storm::service
#
# This module manages storm serviceation
#
# Parameters:
#  [*manage_service*] - whether service should be manged by system default
#                       init system
#  [*enable*]         - automatic sevice start (`manage_service` must be `true`)
#  [*jvm_memory*]     - maximum memory for JVM
#  [*opts*]           - Java options which will be passed to service
#
#
# Requires: storm::install
#
# Sample Usage: storm::service { 'nimbus':
#                 manage_service => true,
#                 jvm_memory     => '1024m',
#                 opts           => ['-Dlog4j.configuration=file:/etc/storm/storm.log.properties', '-Dlogfile.name=nimbus.log']
#               }
#
define storm::service(
  $ensure_service        = 'running',
  $manage_service        = false,
  $force_provider        = undef,
  $config_file           = '/etc/storm/storm.yaml',
  $enable                = true,
  $jvm_memory            = '768m',
  $opts                  = [],
  $user                  = 'root',
  $owner                 = 'root',
  $use_systemd_templates = false,
  ) {

    # The included systemd templates are provided in case you want to install from the apache tarball and still have services.
    if $use_systemd_templates {

      file { "/etc/systemd/system/storm-${name}.service":
        content => template("storm/systemd/storm-${name}.service"),
        owner   => $owner,
        group   => $user,
        mode    => '0644',
        require => Class['storm::install'],
      }

      if $manage_service {
        service { "storm-${name}":
          ensure  => $ensure_service,
          enable  => $enable,
          require => File["/etc/systemd/system/storm-${name}.service"]
        }
      }

    } else { # Not using the included systemd templates (provided in case you want to install from the apache tarball)

      file { "/etc/default/storm-${name}":
        content => template('storm/default-service.erb'),
        owner   => $owner,
        group   => $user,
        mode    => '0644',
        require => Class['storm::install'],
      }

      notify { "storm-${name}":
        message  =>   "service ${name} enable ${enable} manage ${manage_service}",
        withpath => true,
      }

      if $manage_service {
        service { "storm-${name}":
          ensure     => $ensure_service,
          hasstatus  => true,
          hasrestart => true,
          enable     => $enable,
          provider   => $force_provider,
          require    => File["/etc/default/storm-${name}"],
          subscribe  => [ File[$config_file],
            File['/etc/default/storm'],
            File["/etc/default/storm-${name}"]
          ],
        }
      }
    }
}
