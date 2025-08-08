### CLOUD vars
variable "cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

variable "token_gitlab_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/token/get-id"
}

variable "vpc_name_develop" {
  type        = string
  default     = "develop"
  description = "VPC network name"
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}

variable "public_subnets" {
  description = "VPC public subnet config"
  type = list(object({
    name        = string
    zone        = string
    cidr_blocks = list(string)
  }))
  default = [
   {
      name        = "public-a"
      zone        = "ru-central1-a"
      cidr_blocks = ["192.168.10.0/24"]
    },
    {
      name        = "public-b"
      zone        = "ru-central1-b"
      cidr_blocks = ["192.168.11.0/24"]
    },
    {
      name        = "public-d"
      zone        = "ru-central1-d"
      cidr_blocks = ["192.168.12.0/24"]
    }
  ]
}

### HOST vars
variable "vms_resources" {
  description = "Configuration K8s node"
  type = map(object({
    platform_id   = string
    cores         = number
    core_fraction = number
    memory        = number
    disk_type     = string
    disk_size     = number
    preemptible   = bool
    runtime_type  = string
  }))
  default = {
    node-k8s = {
      platform_id   = "standard-v3"
      cores         = 2
      core_fraction = 20
      memory        = 4
      disk_type     = "network-hdd"
      disk_size     = 20
      preemptible   = true
      runtime_type  = "containerd"
    }
  }
}

variable  "vm_image" {
  type        = string
  default     = "ubuntu-2404-lts-oslogin"
  description = "Ubuntu release 24.04-lts"
}

variable "subnet_count" {
  type        = number
  default     = 3
}