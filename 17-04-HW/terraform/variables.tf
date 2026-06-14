variable "cloud_id" {
  description = "Yandex Cloud ID. Можно оставить null и передать через YC_CLOUD_ID."
  type        = string
  default     = null
}

variable "folder_id" {
  description = "Yandex Cloud Folder ID. Можно оставить null и передать через YC_FOLDER_ID."
  type        = string
  default     = null
}

variable "default_zone" {
  description = "Зона доступности для учебных ВМ"
  type        = string
  default     = "ru-central1-a"
}

variable "project_name" {
  description = "Префикс имён ресурсов"
  type        = string
  default     = "ansible-03"
}

variable "vpc_cidr" {
  description = "CIDR подсети для трёх ВМ"
  type        = string
  default     = "10.30.0.0/24"
}

variable "allowed_ssh_cidr" {
  description = "CIDR, с которого разрешён SSH. Для ДЗ можно 0.0.0.0/0, безопаснее указать свой IP/32."
  type        = string
  default     = "0.0.0.0/0"
}

variable "ssh_user" {
  description = "Пользователь в Ubuntu-образе"
  type        = string
  default     = "ubuntu"
}

variable "ssh_public_key" {
  description = "Содержимое публичного SSH-ключа, например из ~/.ssh/id_ed25519.pub"
  type        = string
  sensitive   = true
}

variable "ssh_private_key_file" {
  description = "Путь к приватному ключу на машине, где будет запускаться ansible-playbook"
  type        = string
  default     = "~/.ssh/id_ed25519"
}

variable "vm_platform_id" {
  description = "Платформа ВМ Yandex Compute Cloud"
  type        = string
  default     = "standard-v3"
}

variable "preemptible" {
  description = "Создавать прерываемые ВМ для экономии бюджета"
  type        = bool
  default     = true
}

variable "vm_resources" {
  description = "Ресурсы ВМ по ролям"
  type = map(object({
    cores         = number
    memory        = number
    core_fraction = number
    disk_size     = number
  }))

  default = {
    clickhouse = {
      cores         = 2
      memory        = 4
      core_fraction = 20
      disk_size     = 20
    }
    vector = {
      cores         = 2
      memory        = 2
      core_fraction = 20
      disk_size     = 20
    }
    lighthouse = {
      cores         = 2
      memory        = 2
      core_fraction = 20
      disk_size     = 20
    }
  }
}
