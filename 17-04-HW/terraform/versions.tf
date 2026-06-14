terraform {
  required_version = ">= 1.8.4"

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">= 0.135.0"
    }

    local = {
      source  = "hashicorp/local"
      version = ">= 2.5.0"
    }
  }
}
