### ssh vars
locals {
  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
  }
}

#locals {
#  gitlab-token = "glrt-nZSsMLcx-4htPbH3RBT4i286MQpwOjE3NTZydgp0OjMKdTpoa2V3ZBg.01.1j12q9vou"
#}