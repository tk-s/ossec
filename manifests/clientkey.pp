#
define ossec::clientkey (
    $client_id,
    $client_name,
    $client_ip,
    $client_seed    = $ossec::params::client_seed
    ) {

    if !$client_seed or $client_seed == 'undef' {
        fail("Ossec::Clientkey parameter client_seed is not set!")
    }

    $key1 = md5("${client_id} ${client_seed}")
    $key2 = md5("${client_name} ${client_ip} ${client_seed}")

    concat::fragment { "ossec-client-key-${client_ip}-${client_name}":
        ensure  => present,
        target  => "$ossec::params::client_keys",
        order   => "${client_id}",
        content => "${client_id} ${client_name} ${client_ip} ${key1}${key2}\n",
    }
}
