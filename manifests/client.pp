#
class ossec::client(
    $client_ip = $::ipaddress,
    $ossec_dir = $ossec::params::ossec_dir,
    $client_seed = $ossec::params::client_seed
) {
    class { "ossec::service":
        service_name => $operatingsystem ? {
            'Debian' => 'ossec-hids-agent',
            default => 'ossec-hids'
        }
    }
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
        client_id   => pick($::ossec_id, $::uniqueid),
        client_name => $::fqdn,
        client_ip   => $client_ip,
    }
    # send to server, requires storeconfigs
    @@ossec::clientkey { "ossec_key_${::fqdn}_server":
        client_id   => pick($::ossec_id, $::uniqueid),
        client_name => $::fqdn,
        client_ip   => $client_ip,
    }
}

apt-get update && aptitude -o Dpkg::Options::="--force-confold" -y dist-upgrade && aptitude -o Dpkg::Options::="--force-confold" -y  install postgresql-9.3-pgstatplans postgresql-contrib-9.3
touch /etc/postgresql/9.3/main/postgresql_puppet_extras.conf && pg_dropcluster 9.3 main --stop && pg_upgradecluster 9.1 main


