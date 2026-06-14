provider "yandex" {
  # Можно не заполнять cloud_id/folder_id в tfvars, если используются переменные окружения:
  # YC_TOKEN, YC_CLOUD_ID, YC_FOLDER_ID.
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.default_zone
}
