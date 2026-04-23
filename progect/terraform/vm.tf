# === VIRTUAL MACHINE WITH CLOUD-INIT ===
resource "yandex_compute_instance" "app_vm" {
  name        = var.vm_name
  description = "VM for web application with Docker"
  hostname    = var.vm_name

  zone      = var.zone
  folder_id = var.yc_folder_id

  # Платформа и ресурсы
  platform_id = var.vm_platform

  resources {
    cores  = var.vm_cores
    memory = var.vm_memory
  }

  # Boot disk с Ubuntu
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
      name     = "${var.vm_name}-boot-disk"
      type     = "network-ssd"
      size     = var.vm_disk_size
    }
  }

  # Network interface с публичным IP
  network_interface {
    subnet_id          = yandex_vpc_subnet.app_subnet.id
    nat                = true # Публичный IP
    security_group_ids = [yandex_vpc_security_group.web_sg.id]
  }

  # METADATA
  metadata = {
    # SSH-ключ для доступа
    ssh-keys = "ubuntu:${var.ssh_public_key}"

    # Cloud-init с подстановкой переменных
    user-data = templatefile("${path.module}/cloud-init.yaml.tftpl", {
      db_host     = yandex_mdb_mysql_cluster.app_db.host[0].fqdn
      db_user     = "app_user"
      db_password = var.db_password
      db_name     = "app_db"
      registry_id = yandex_container_registry.app_registry.id
    })
  }

  # Выводим полезную информацию
  lifecycle {
    ignore_changes = [
      # Игнорируем изменения метаданных при повторном apply
      metadata["ssh-keys"],
    ]
  }
}

# === Образ ===
# В файле terraform/vm.tf

data "yandex_compute_image" "ubuntu" {
  family    = "ubuntu-2004-lts"
  folder_id = "standard-images"
}

# === OUTPUTS: информация о ВМ ===
output "vm_id" {
  description = "ID виртуальной машины"
  value       = yandex_compute_instance.app_vm.id
}

output "vm_public_ip" {
  description = "Публичный IP адрес ВМ"
  value       = yandex_compute_instance.app_vm.network_interface[0].nat_ip_address
}

output "vm_internal_ip" {
  description = "Внутренний IP адрес ВМ"
  value       = yandex_compute_instance.app_vm.network_interface[0].ip_address
}

output "vm_fqdn" {
  description = "FQDN виртуальной машины"
  value       = yandex_compute_instance.app_vm.fqdn
}
