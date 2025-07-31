resource "yandex_vpc_network" "develop" {
  name = var.vpc_name_develop
}

resource "yandex_vpc_subnet" "public" {
  count          = var.subnet_count
  name           = var.public_subnets[count.index].name
  zone           = var.public_subnets[count.index].zone
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = var.public_subnets[count.index].cidr_blocks
}