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

      #"kubectl --namespace monitoring get networkpolicies,"
      #"kubectl -n monitoring delete networkpolicies.networking.k8s.io --all,"
      
      # Доступ к Prometheus, Alertmanager, Grafana используя NodePort
      "kubectl --namespace monitoring patch svc prometheus-k8s -p '{\"spec\": {\"type\": \"NodePort\"}}'",
      "kubectl --namespace monitoring patch svc alertmanager-main -p '{\"spec\": {\"type\": \"NodePort\"}}'",
      "kubectl --namespace monitoring patch svc grafana -p '{\"spec\": {\"type\": \"NodePort\"}}'"
    ]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/id_ed25519")
      host        = yandex_compute_instance.k8s-node[0].network_interface[0].nat_ip_address
    }
  }
}