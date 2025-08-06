
resource "null_resource" "deploy_nginx" {
  depends_on = [
    null_resource.deploy_k8s
  ]
  
  provisioner "remote-exec" {
    inline = [
      "cd ..",
      # Gitlab Install
      "curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh | sudo bash",
      "sudo apt install gitlab-runner",
      "gitlab-runner register --url https://gitlab.com  --token ${local.gitlab-token} --executor shell --name k8s-runer",


      #Клонируем  kube-prometheus репозиторий
  #    "git clone https://github.com/prometheus-operator/kube-prometheus.git",
  #    "cd kube-prometheus",

      #Deploy Prometheus Monitoring Stack on Kubernetes
  #    "kubectl create -f manifests/setup",
  #    "kubectl create -f manifests/",

      #"kubectl --namespace monitoring get networkpolicies,"
      #"kubectl -n monitoring delete networkpolicies.networking.k8s.io --all,"
      
      # Доступ к Prometheus, Alertmanager, Grafana используя NodePort
  #    "kubectl --namespace monitoring patch svc prometheus-k8s -p '{\"spec\": {\"type\": \"NodePort\"}}'",
  #    "kubectl --namespace monitoring patch svc alertmanager-main -p '{\"spec\": {\"type\": \"NodePort\"}}'",
  #    "kubectl --namespace monitoring patch svc grafana -p '{\"spec\": {\"type\": \"NodePort\"}}'"
    ]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/id_ed25519")
      host        = yandex_compute_instance.k8s-node[0].network_interface[0].nat_ip_address
    }
  }
}