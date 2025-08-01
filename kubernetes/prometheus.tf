resource "null_resource" "deploy_grafana" {
  depends_on = [
    null_resource.deploy_k8s
  ]
  
  provisioner "remote-exec" {
    inline = [
      # Установка Helm
      "curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash",
    
      # Установка prometheus-operator deployment
    #  "kubectl create ns monitoring",
      "git clone https://github.com/coreos/prometheus-operator.git",
    
      "cd /home/ubuntu/prometheus-operator",
      "helm install  --set rbacEnable=true helm/prometheus-operator",
      
      # Установка Prometheus, Alertmanager specs, Grafana deployment, kube-prometheus
      "helm install --name prometheus --set serviceMonitorsSelector.app=prometheus --set ruleSelector.app=prometheus helm/prometheus",
      "helm install --name alertmanager helm/alertmanager",
      "helm install --name grafana helm/grafana",
      "helm install --name kube-prometheus helm/kube-prometheus"
    ]  
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/id_ed25519")
      host        = yandex_compute_instance.k8s-node[0].network_interface[0].nat_ip_address
    }
  }
}