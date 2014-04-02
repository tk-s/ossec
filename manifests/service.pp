#
class ossec::service {
    service { 'ossec':
        name        => $ossec::config::install_type ? {
            "server" => $ossec::params::server_service_name,
            default => $ossec::params::client_service_name
        },
        enable      => true,
        ensure      => running,
        hasrestart  => true,
        hasstatus   => true,
        require     => Package['ossec'],
    }
}
