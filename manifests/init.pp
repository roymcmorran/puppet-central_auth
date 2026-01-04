# == Class: central_auth
#
# A module to manage Authentication using SSSD and PAM
class central_auth (
  # Class parameters are populated from External(hiera)/Defaults/Fail
  Boolean $manage_auth                = false,
  Boolean $enable_sssd                = true,
  Boolean $enable_pam_access          = false,
  Boolean $manage_pam_files           = true,
) {

  case $facts['os']['family'] {
    'Suse': {
      if Numeric($facts['os']['release']['major']) < 11 {
        fail("Wrong SLES version, should be 11 or greater than 11, not ${facts['os']['release']['major']}")
      }
    }
    'RedHat': {
      if Numeric($facts['os']['release']['major']) < 6 and $facts['os']['name'] != 'Amazon' {
        fail("Wrong RedHat version, should be 6 or greater than 6, not ${facts['os']['release']['major']}")
      }
    }
    'Debian': {
      if Numeric($facts['os']['release']['major']) < 7 and $facts['os']['name'] == 'Debian' {
        fail("Wrong Debian version, should be 7 or greater than 7, not ${facts['os']['release']['major']}")
      } elsif Numeric($facts['os']['release']['major']) < 12 and $facts['os']['name'] == 'Ubuntu' {
        fail("Wrong Debian version, should be 12 or greater than 12, not ${facts['os']['release']['major']}")
      }
    }
    default: {
      fail("Wrong OS Family, should be RedHat, Debian or Suse, not ${facts['os']['family']}")
    }
  }

  if $manage_auth {

    class { 'central_auth::install': }

    -> class { 'central_auth::config': }

    -> class { 'central_auth::pam': }

    -> class { 'central_auth::join_ad': }

    -> class { 'central_auth::service': }

  }
}
