# Manage sysctl value
#
# It not only manages the entry within
# /etc/sysctl.conf, but also checks the
# current active version.
define sysctl::value (
  $value,
  $key    = $name,
  $target = undef,
) {
  include sysctl::params
  $array = split($value,'[\s\t]')
  $val1 = inline_template("<%= @array.reject(&:empty?).flatten.join(\"\t\") %>")

  sysctl { $key :
    val     => $val1,
    target  => $target,
    require => File['/etc/sysctl.conf'],
  }

  sysctl_runtime { $key:
    val => $val1,
  }
}
