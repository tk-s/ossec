#
class ossec::service {
    service { 'ossec':
        name        => $ossec::config::service_name,
        enable      => true,
        ensure      => running,
        hasrestart  => true,
        hasstatus   => true,
        require     => Package['ossec'],
    }
}
