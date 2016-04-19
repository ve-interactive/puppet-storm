# Class: storm::install
#
# This module manages storm installation
#
# Parameters: None
#
# Actions: None
#
#
# Normally we need just 'storm' package, however you might want to pass
# other dependencies, like 'libjzmq' etc.
#
#
class storm::install(
  $packages = ['storm'],
  $ensure   = 'latest',
  $from_tarball = false,
  $version,
  $home,
  $conf,
  $apache_repo_url,
) {

  if $from_tarball {
    ensure_resource('package', 'wget', {'ensure' => present })

    exec { 'download_storm_tarball':
      command => "/usr/bin/wget ${apache_repo_url}/apache-storm-${version}/apache-storm-${version}.tar.gz",
      cwd     => '/tmp',
      creates => "/tmp/apache-storm-${version}.tar.gz",
    }

    exec { 'decompress_tarball':
      command => "/usr/bin/tar -xzf /tmp/apache-storm-${version}.tar.gz",
      cwd     => '/usr/lib',
      creates => "/usr/lib/apache-storm-${version}",
      require => Exec['download_storm_tarball'],
    }

    file { $home:
      ensure  => 'link',
      force   => true,
      target  => "/usr/lib/apache-storm-${version}",
      require => Exec['decompress_tarball'],
    }

    file { $conf:
      ensure  => 'link',
      force   => true,
      target  => "/usr/lib/apache-storm-${version}/conf",
      require => File[$home],
    }

    file { '/var/log/storm':
        ensure => 'directory'
    }

    file { "${home}/logs":
        ensure => 'link',
        target => '/var/log/storm',
        require => File['/var/log/storm'],
    }


  } else {
    ensure_resource('package', $packages, {'ensure' => $ensure })
  }

}
