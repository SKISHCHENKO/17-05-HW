output "vm_public_ips" {
  description = "Публичные IP ВМ для SSH/Ansible"
  value = {
    for role, instance in yandex_compute_instance.vm : role => instance.network_interface[0].nat_ip_address
  }
}

output "vm_private_ips" {
  description = "Внутренние IP ВМ"
  value = {
    for role, instance in yandex_compute_instance.vm : role => instance.network_interface[0].ip_address
  }
}

output "ansible_inventory" {
  description = "Сгенерированный inventory для Ansible"
  value       = abspath(local_file.ansible_inventory.filename)
}

output "lighthouse_url" {
  description = "URL LightHouse"
  value       = "http://${yandex_compute_instance.vm["lighthouse"].network_interface[0].nat_ip_address}/"
}

output "lighthouse_clickhouse_proxy" {
  description = "HTTP proxy до ClickHouse через nginx на LightHouse"
  value       = "http://${yandex_compute_instance.vm["lighthouse"].network_interface[0].nat_ip_address}/clickhouse/"
}
