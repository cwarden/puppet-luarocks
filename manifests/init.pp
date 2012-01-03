# luarocks module
# based on rubygems module by luke kanies (http://github.com/lak)
#
# Copyright 2011, SwellPath, Inc.
# Christian G. Warden <cwarden@xerus.org>

class luarocks {
  package{'luarocks':
    ensure => installed,
  }
}

