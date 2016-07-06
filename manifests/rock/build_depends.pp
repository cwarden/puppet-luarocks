class luarocks::rock::build_depends {
  Package { ensure => present }
  package {
    'make':;
  }
}
