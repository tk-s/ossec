#
class ossec::service (
  $service_name
){
    service { 'ossec':
        name        => $service_name,
        enable      => true,
        ensure      => running,
        hasrestart  => true,
        hasstatus   => true,
        require     => Package['ossec'],
    }
}
