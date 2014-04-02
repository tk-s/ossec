#
class ossec::client(
    $ossec_dir = $ossec::params::ossec_dir,
    $client_seed = $ossec::params::client_seed
) {
    class { "ossec::service": }
    class { "ossec::config": install_type => "client", ossec_dir => "${ossec_dir}", client_seed => "${client_seed}" }

    package { 'ossec':
        ensure  => installed,
        name    => $ossec::params::client_package_name,
    }
    #
    concat { "${ossec::params::client_keys}":
        owner   => 'root',
        group   => $ossec::params::group,
        mode    => '0440',
        require => Package['ossec'],
        notify  => Class['Ossec::Service'],
    }
    # set key on the client
    ossec::clientkey { "ossec_key_${::fqdn}_client":
        client_id   => $::uniqueid,
        client_name => $::fqdn,
        client_ip   => $::ipaddress,
    }
    # send to server, requires storeconfigs
    @@ossec::clientkey { "ossec_key_${::fqdn}_server":
        client_id   => $::uniqueid,
        client_name => $::fqdn,
        client_ip   => $::ipaddress,
    }
}
