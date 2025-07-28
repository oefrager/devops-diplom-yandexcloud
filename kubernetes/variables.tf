### CLOUD vars
variable "cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
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
  type = map(object({
    name        = string
    zone        = string
    cidr_blocks = list(string)
  }))
  default = {
    "public-a" = {
      name        = "public-a"
      zone        = "ru-central1-a"
      cidr_blocks = ["192.168.10.0/24"]
    },
    "public-b" = {
      name        = "public-b"
      zone        = "ru-central1-b"
      cidr_blocks = ["192.168.11.0/24"]
    },
    "public-d" = {
      name        = "public-d"
      zone        = "ru-central1-d"
      cidr_blocks = ["192.168.12.0/24"]
    }
  }
}

#variable "private_subnets" {
#  description = "VPC private subnet config"
#  type = map(object({
#    name        = string
#    zone        = string
#    cidr_blocks = list(string)
#  }))
#  default = {
#    "private-a" = {
#      name        = "private-a"
#      zone        = "ru-central1-a"
#      cidr_blocks = ["192.168.20.0/24"]
#    },
#    "private-b" = {
#      name        = "private-b"
#      zone        = "ru-central1-b"
#      cidr_blocks = ["192.168.21.0/24"]
#    }
#  }
#}
