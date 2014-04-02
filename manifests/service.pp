#
class ossec::service {
    if !defined(Class['ossec::params']) {
        class { "ossec::params":
            install_type => $ossec::config::install_type
        }
    }
    service { 'ossec':
        name        => $ossec::params::service_name,
        enable      => true,
        ensure      => running,
        hasrestart  => true,
        hasstatus   => true,
        require     => Package['ossec'],
    }
}
