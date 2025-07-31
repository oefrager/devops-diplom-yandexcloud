data "yandex_compute_image" "image_os" {
  family = var.vm_image
}

resource "yandex_compute_instance" "k8s-node" {
  count       = 3
  name        = "host-${count.index+1}"
  hostname    = "host-${count.index+1}"
  platform_id = var.vms_resources.node-k8s.platform_id
  zone        = var.public_subnets[count.index % var.subnet_count].zone
  resources {
    cores         = var.vms_resources.node-k8s.cores
    memory        = var.vms_resources.node-k8s.memory
    core_fraction = var.vms_resources.node-k8s.core_fraction
    }
  
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.image_os.id
      type     = var.vms_resources.node-k8s.disk_type
      size     = var.vms_resources.node-k8s.disk_size
    }
  }
  
  scheduling_policy { preemptible = var.vms_resources.node-k8s.preemptible }
  
  network_interface {
    subnet_id          = yandex_vpc_subnet.public[count.index % var.subnet_count].id
    nat                = true
    }
  
  allow_stopping_for_update = true
  metadata = local.metadata
}