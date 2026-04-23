# === VPC NETWORK ===
resource "yandex_vpc_network" "app_network" {
  name        = "${var.vm_name}-network"
  description = "VPC for final project infrastructure"
}

# === SUBNET ===
resource "yandex_vpc_subnet" "app_subnet" {
  name           = "${var.vm_name}-subnet"
  zone           = var.zone
  network_id     = yandex_vpc_network.app_network.id
  v4_cidr_blocks = ["10.0.1.0/24"]
}

# === SECURITY GROUP: WEB APPLICATION (порты 22, 80, 443) ===
resource "yandex_vpc_security_group" "web_sg" {
  name        = "${var.vm_name}-web-sg"
  description = "Security group for web app (SSH, HTTP, HTTPS)"
  network_id  = yandex_vpc_network.app_network.id

  # SSH
  ingress {
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
    description    = "Allow SSH access"
  }

  # HTTP
  ingress {
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
    description    = "Allow HTTP traffic"
  }

  # HTTPS
  ingress {
    protocol       = "TCP"
    port           = 443
    v4_cidr_blocks = ["0.0.0.0/0"]
    description    = "Allow HTTPS traffic"
  }

  # Egress: разрешаем весь исходящий трафик
  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    description    = "Allow all outbound traffic"
  }
}


# === SECURITY GROUP: MANAGED MYSQL (порт 3306, только из нашей подсети) ===
resource "yandex_vpc_security_group" "db_sg" {
  name        = "${var.vm_name}-db-sg"
  description = "Security group for Managed MySQL"
  network_id  = yandex_vpc_network.app_network.id

  # MySQL
  ingress {
    protocol       = "TCP"
    port           = 3306
    v4_cidr_blocks = [yandex_vpc_subnet.app_subnet.v4_cidr_blocks[0]]
    description    = "Allow MySQL access only from app subnet"
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    description    = "Allow all outbound traffic"
  }
}
