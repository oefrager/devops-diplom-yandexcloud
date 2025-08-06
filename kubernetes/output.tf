output "k8s_nodes" {
  value = [for i in yandex_compute_instance.k8s-node[*] : {
    ip_external = i.network_interface[0].nat_ip_address
    ip_internal = i.network_interface[0].ip_address
    name        = i.name
  }]
}

output "load_balanser" {
  value = {
    ip_external =yandex_lb_network_load_balancer.load-balancer.listener[*].external_address_spec[*].address
  }
}