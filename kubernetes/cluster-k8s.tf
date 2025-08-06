resource "local_file" "ansible_inventory_k8s" {
  content = templatefile("./infrastructure/inventory.tftpl", {
    master-node_internal_ip = yandex_compute_instance.k8s-node[0].network_interface[0].ip_address
    node_internal_ip = slice(yandex_compute_instance.k8s-node[*].network_interface[0].ip_address, 1, 3),
  })
  filename = "./infrastructure/inventory.yml"
}

#resource "local_file" "ansible_inventory_master" {
#  content = templatefile("./infrastructure/hosts.tftpl", {
#    master_internal_ip = yandex_compute_instance.k8s-node[0].network_interface[0].ip_address
#  })
#  filename = "./infrastructure/hosts.yml"
#}

resource "null_resource" "deploy_k8s" {
  depends_on = [
    yandex_compute_instance.k8s-node,
    local_file.ansible_inventory_k8s
  ]

# Копируем inventory файл
  provisioner "file" {
    source      = "${path.module}/infrastructure/inventory.yml"
    destination = "/home/ubuntu/inventory.yml"
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/id_ed25519")
      host        = yandex_compute_instance.k8s-node[0].network_interface[0].nat_ip_address
    }
  }
  
  provisioner "file" {
    source      = "~/.ssh/id_ed25519"
    destination = "/home/ubuntu/.ssh/id_ed25519"
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/id_ed25519")
      host        = yandex_compute_instance.k8s-node[0].network_interface[0].nat_ip_address
    }
  }

  provisioner "remote-exec" {
    inline = [
      # Установка Python
      "sudo apt-get update",
      "sudo apt-get install -y python3-pip python3-venv python3-full git mc",

      # Клонирование Kubespray
      "git clone https://github.com/kubernetes-sigs/kubespray.git",

      # Создание и активация виртуального окружения
      "python3 -m venv /home/ubuntu/venv",
      ". /home/ubuntu/venv/bin/activate",
      "/home/ubuntu/venv/bin/pip3 install -r /home/ubuntu/kubespray/requirements.txt",

      # Права доступа для SSH ключа
      "chmod 600 /home/ubuntu/.ssh/id_ed25519",

      # Запуск Kubespray
      "cd /home/ubuntu/kubespray",
      "ansible-playbook -i /home/ubuntu/inventory.yml /home/ubuntu/kubespray/cluster.yml -b -v",

      # Настройка конфигурации cubectl
      "mkdir -p /home/ubuntu/.kube",
      "sudo cp -i /etc/kubernetes/admin.conf /home/ubuntu/.kube/config",
      "sudo chown $(id -u):$(id -g) /home/ubuntu/.kube/config",

      "rm -f /home/ubuntu/.ssh/id_ed25519"
    ]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/id_ed25519")
      host        = yandex_compute_instance.k8s-node[0].network_interface[0].nat_ip_address
    }
  }
}