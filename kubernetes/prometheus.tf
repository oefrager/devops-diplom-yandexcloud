# Network Load Balancer for Grafana
resource "yandex_lb_network_load_balancer" "load-balancer" {
  name = "load-balancer"
  listener {
    name = "load-balancer-chek"
    port = 80
    target_port = 30620 ###
    external_address_spec {
      ip_version = "ipv4"
    }
  }
  attached_target_group {
    target_group_id = yandex_lb_target_group.target_group.id
    healthcheck {
      name = "http"
      http_options {
        port = 30620 ###
        path = "/api/health"
      }
    }
  }
}

resource "null_resource" "deploy_grafana" {
  depends_on = [
    null_resource.deploy_k8s
  ]
  
  provisioner "remote-exec" {
    inline = [
      # Helm Install
      "curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash",
    
      #Клонируем  kube-prometheus репозиторий
      "git clone https://github.com/prometheus-operator/kube-prometheus.git",
      "cd kube-prometheus",

      #Deploy Prometheus Monitoring Stack on Kubernetes
      "kubectl create -f manifests/setup",
      "kubectl create -f manifests/",

      #"kubectl --namespace monitoring get networkpolicies"
      "kubectl -n monitoring delete networkpolicies.networking.k8s.io --all",
      
      # Доступ к Prometheus, Alertmanager, Grafana используя NodePort
      "kubectl --namespace monitoring patch svc prometheus-k8s -p '{\"spec\": {\"type\": \"LoadBalancer\"}}'",
      "kubectl --namespace monitoring patch svc alertmanager-main -p '{\"spec\": {\"type\": \"LoadBalancer\"}}'",
      #"kubectl --namespace monitoring patch svc grafana -p '{\"spec\": {\"type\": \"LoadBalancer\"}}'",
      "kubectl --namespace monitoring patch svc grafana -p '{\"spec\": {\"ports\": [{\"port\":3000 ,\"targetPort\": 32100,\"name\": \"http\"}], \"type\": \"LoadBalancer\"}}",
    ]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/id_ed25519")
      host        = yandex_compute_instance.k8s-node[0].network_interface[0].nat_ip_address
    }
  }
}

# Target Group for Network Load Balancer
resource "yandex_lb_target_group" "target_group" {
  depends_on = [yandex_compute_instance.k8s-node]
  name       = "target-group"
  target {
    subnet_id = yandex_compute_instance.k8s-node[0].network_interface[0].subnet_id
    address   = yandex_compute_instance.k8s-node[0].network_interface[0].ip_address
  }
}

