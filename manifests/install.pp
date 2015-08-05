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
  $ensure   = '0.9.4.1',
) {

  package { 'storm': ensure => $ensure}
  #ensure_resource('package', $packages, {'ensure' => $ensure })

}
