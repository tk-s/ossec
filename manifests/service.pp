#
class ossec::service {
    service { 'ossec':
        name        => $ossec::params::service_name,
        enable      => true,
        ensure      => running,
        hasrestart  => true,
        hasstatus   => true,
        require     => Package['ossec'],
    }
}
