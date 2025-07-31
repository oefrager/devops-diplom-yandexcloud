output "k8s_nodes" {
  value = [for i in yandex_compute_instance.k8s-node[*] : {
    ip_external = i.network_interface[0].nat_ip_address
    ip_internal = i.network_interface[0].ip_address
    name        = i.name
  }]
}