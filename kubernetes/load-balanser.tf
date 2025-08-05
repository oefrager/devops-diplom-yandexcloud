# Target Group for Network Load Balancer
resource "yandex_lb_target_group" "target_group" {
  depends_on = [yandex_compute_instance.k8s-node]
  name       = "target-group"
  target {
    subnet_id = yandex_compute_instance.k8s-node[0].network_interface[0].subnet_id
    address   = yandex_compute_instance.k8s-node[0].network_interface[0].ip_address
  }
}

# Network Load Balancer for Grafana
resource "yandex_lb_network_load_balancer" "load-balancer" {
  name = "load-balancer"
  listener {
    name = "load-balancer-chek"
    port = 80
    target_port = 32108 # NodePort для Grafana 30000
    external_address_spec {
      ip_version = "ipv4"
    }
  }
  attached_target_group {
    target_group_id = yandex_lb_target_group.target_group.id
    healthcheck {
      name = "http"
      http_options {
        port = 32108 #30000
        path = "/api/health"
      }
    }
  }
}