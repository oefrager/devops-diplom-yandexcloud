
# Сервисный аккаунт для bucket.
resource "yandex_iam_service_account" "backet-sa" {
  folder_id   = var.folder_id
  name        = "bucket-sa"
  description = "Service account for the backet"
}

# Сервисному аккаунту назначаются роли.
resource "yandex_resourcemanager_folder_iam_member" "bucket_editor" {
  folder_id   = var.folder_id
  role        = "storage.admin"
  member      = "serviceAccount:${yandex_iam_service_account.backet-sa.id}"
  depends_on  = [yandex_iam_service_account.backet-sa]
}

resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = yandex_iam_service_account.backet-sa.id
  description        = "Static access key for object storage"
}

# Ключ Yandex Key Management Service для шифрования.
resource "yandex_kms_symmetric_key" "key-a" {
  name                = "bucket-key"
  default_algorithm   = "AES_256"
  rotation_period     = "8760h"
  deletion_protection = false
#  lifecycle { prevent_destroy = true }
  description         = "Key Management Service (KMS) for bucket "
}

# Storage bucket
resource "yandex_storage_bucket" "state-bucket-goi" {
  bucket    = "state-bucket-goi"
  folder_id = var.folder_id
  #acl       = "private"
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = yandex_kms_symmetric_key.key-a.id
        sse_algorithm     = "aws:kms"
      }
    }
  }
}