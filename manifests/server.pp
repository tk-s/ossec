class ossec::server (
    $enable_db        = $ossec::params::enable_db,
    $enable_debug     = $ossec::params::enable_debug,
    $enable_agentless = $ossec::params::enable_agentless,
    $enable_csyslog   = $ossec::params::enable_csyslog,
    $ossec_dir = $ossec::params::ossec_dir,
    $client_seed = $ossec::params::client_seed
    ) {

    class { "ossec::service":
        service_name => 'ossec-hids-server'
    }
    class { "ossec::config": install_type => "server", ossec_dir => "${ossec_dir}", client_seed => "${client_seed}" }

    #
    package { 'ossec':
        name    => $ossec::params::server_package_name,
        ensure  => installed,
    }
    #
    file { 'pfile':
        name    => $ossec::params::plist_file,
        ensure  => file,
        owner   => $ossec::params::user,
        group   => $ossec::params::group,
        mode    => '0644',
        content => template("ossec/process_list.erb"),
        require => Package['ossec'],
        notify  => Class['Ossec::Service'],
    }
    #
    concat { "${ossec::params::client_keys}":
        owner   => 'root',
        group   => $ossec::params::group,
        mode    => '0440',
        require => Package['ossec'],
        notify  => Class['Ossec::Service'],
    }
    # Add key from agent
    Ossec::Clientkey<<| |>>
}
