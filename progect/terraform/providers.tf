# === ====
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.115"
    }
  }
}

# ===  YANDEX CLOUD PROVIDER CONFIGURATION ===
provider "yandex" {
  service_account_key_file = var.sa_key_file != "" ? var.sa_key_file : null

  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id
  zone      = var.zone
}
