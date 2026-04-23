# === CONTAINER REGISTRY ===
resource "yandex_container_registry" "app_registry" {
  name      = "${var.vm_name}-registry"
  folder_id = var.yc_folder_id
}

# === OUTPUT ===
output "registry_id" {
  description = "ID Container Registry"
  value       = yandex_container_registry.app_registry.id
}
