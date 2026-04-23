# === Хранение state в Yandex Object Storage (S3-compatible) ===
terraform {
  backend "s3" {
    endpoints = {
      s3 = "https://storage.yandexcloud.net"
    }

    bucket = "tf-state-home-17-final-project"
    key    = "terraform/yc-final-project.tfstate"
    region = "ru-central1"

    use_path_style = true

    # Пропускаем проверки AWS (мы в Yandex Cloud)
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }
}
