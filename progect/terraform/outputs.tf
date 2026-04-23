output "vpc_id" {
  description = "ID VPC сети"
  value       = yandex_vpc_network.app_network.id
}

output "subnet_id" {
  description = "ID подсети"
  value       = yandex_vpc_subnet.app_subnet.id
}
