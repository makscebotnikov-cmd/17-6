# === MANAGED MYSQL CLUSTER ===
resource "yandex_mdb_mysql_cluster" "app_db" {
  name        = "${var.vm_name}-mysql"
  environment = "PRESTABLE"
  network_id  = yandex_vpc_network.app_network.id

  version = "8.0"

  resources {
    resource_preset_id = "s2.micro"
    disk_size          = 10
    disk_type_id       = "network-ssd"
  }

  user {
    name     = "app_user"
    password = var.db_password

    permission {
      database_name = "app_db"
      roles         = ["ALL"]
    }
  }

  database {
    name = "app_db"
  }

  host {
    name      = "mysql-host"
    zone      = var.zone
    subnet_id = yandex_vpc_subnet.app_subnet.id
  }
}

# === OUTPUTS ===
output "db_endpoint" {
  description = "MySQL endpoint"
  value       = yandex_mdb_mysql_cluster.app_db.host[0].fqdn
  sensitive   = false
}

output "db_name" {
  value = "app_db"
}

output "db_user" {
  value = "app_user"
}
