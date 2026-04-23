# === Обязательные переменные ====

variable "yc_cloud_id" {
  description = "ID облака в Yandex Cloud"
  type        = string
}

variable "yc_folder_id" {
  description = "ID фолдера для развертывания"
  type        = string
}

variable "sa_key_file" {
  description = "Путь к ключу сервисного аккаунта (key.json). Оставьте пустым, если используете токен."
  type        = string
  default     = ""
  sensitive   = true
}

# === Опциональные переменные ====

variable "region" {
  description = "Регион развертывания"
  type        = string
  default     = "ru-central1"
}

variable "zone" {
  description = "Зона доступности"
  type        = string
  default     = "ru-central1-a"
}

variable "vm_name" {
  description = "Имя виртуальной машины"
  type        = string
  default     = "web-app-node"
}

variable "vm_platform" {
  description = "Платформа ВМ (standard-v1, standard-v2, standard-v3)"
  type        = string
  default     = "standard-v3"
}

variable "vm_cores" {
  description = "Количество vCPU"
  type        = number
  default     = 2
}

variable "vm_memory" {
  description = "Объем памяти в ГБ"
  type        = number
  default     = 2
}

variable "vm_disk_size" {
  description = "Размер диска в ГБ"
  type        = number
  default     = 20
}

variable "vm_image_family" {
  description = "Семейство образов ОС"
  type        = string
  default     = "ubuntu2204"
}

variable "ssh_public_key" {
  description = "Публичный SSH-ключ для доступа к ВМ"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Пароль для пользователя БД"
  type        = string
  sensitive   = true
}
