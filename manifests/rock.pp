# Installs lua rocks
# As a name it expects the name of the rock.
# If you want to want to install a certain version
# you have to append the version to the rock name:
#
#    install a version of luasocket:
#       luarocks::rock{'luasocket': }
#
#    install version 2.0.2 of luasocket:
#       luasocket::rock{'luasocket-2.0.2': }
#
#    uninstall luasocket rock (until no such rock is anymore installed):
#       luarocks::rock{'polygot': ensure => absent }
#
#    uninstall luasocket version 2.0.2
#       luarocks::rock{'luasocket-2.0.2': ensure => absent }
#
# You can also enforce to use the luarocks command to manage the rock
# by setting provider to `exec`.
#
define luarocks::rock(
  $ensure = 'present',
  $source = 'absent',
  $provider = 'default',
  $server = undef
) {
  require ::luarocks
  require luarocks::rock::build_depends

  if $name =~ /\-(\d|\.)+$/ {
    $real_name = regsubst($name,'^(.*)-(\d+(\d|\.|-)+)$','\1')
    $rock_version = regsubst($name,'^(.*)-(\d+(\d|\.|-)+)$','\2')
  } else {
    $real_name = $name
  }

  if $source != 'absent' {
    if $ensure != 'absent' {
      require luarocks::rock::cachedir
      exec{"get-rock-$name":
        command => "/usr/bin/wget -O ${luarocks::rock::cachedir::dir}/$name.rock $source",
        creates => "${luarocks::rock::cachedir::dir}/$name.rock",
      }
    } else {
      file{"${luarocks::rock::cachedir::dir}/$name.rock":
        ensure => 'absent';
      }
    }
  }

  if $rock_version {
      $rock_version_str = "${rock_version}"
      $rock_version_check_str = $rock_version
  } else {
      $rock_version_check_str = '.*'
  }

  if $server {
	  $server_param = "--server $server"
  } else {
	  $server_param = ""
  }

  if $ensure == 'present' {
      if $source != 'absent' {
        $rock_cmd = "luarocks $server_param install ${luarocks::rock::cachedir::dir}/${name}.rock"
      } else {
        $rock_cmd = "luarocks $server_param install ${real_name} ${rock_version_str}"
      }
  } else {
      $rock_cmd = "luarocks remove ${real_name} ${rock_version_str}"
  }

  exec{"manage_rock_${name}":
      command => $rock_cmd
  }

  $rock_cmd_check_str = "luarocks list | /egrep -A1 '^${real_name}\\>' | tail -1 | egrep '\\<${rock_version_check_str}\\> \\(installed\\)'"
  if $ensure == 'present' {
      Exec["manage_rock_${name}"]{
         unless => $rock_cmd_check_str,
         path => "/bin:/usr/bin",
      }
  } else {
      Exec["manage_rock_${name}"]{
         onlyif => $rock_cmd_check_str,
         path => "/bin:/usr/bin",
      }
  }
}

