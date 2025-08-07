
resource "null_resource" "deploy_nginx" {
  depends_on = [
    null_resource.deploy_k8s,
    null_resource.deploy_grafana
  ]

# Copy app manifest
  provisioner "file" {
    source      = "${path.module}/infrastructure/deploy.yaml"
    destination = "/home/ubuntu/deploy.yaml"
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/id_ed25519")
      host        = yandex_compute_instance.k8s-node[0].network_interface[0].nat_ip_address
    }
  }

  provisioner "remote-exec" {
    inline = [
      "kubectl apply -f /home/ubuntu/deploy.yaml",

      # Gitlab Install
      "curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh | sudo bash",
      "sudo apt -y install gitlab-runner",
      "gitlab-runner register --non-interactive --url https://gitlab.com  --token ${local.gitlab-token} --executor shell --name k8s-runer",

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