resource "local_file" "ansible_inventory" {
  filename = "${path.module}/../ansible/prod.yml"

  content = templatefile("${path.module}/templates/prod.yml.tftpl", {
    ssh_user             = var.ssh_user
    ssh_private_key_file = var.ssh_private_key_file

    clickhouse_name       = yandex_compute_instance.vm["clickhouse"].name
    clickhouse_public_ip  = yandex_compute_instance.vm["clickhouse"].network_interface[0].nat_ip_address
    clickhouse_private_ip = yandex_compute_instance.vm["clickhouse"].network_interface[0].ip_address

    vector_name      = yandex_compute_instance.vm["vector"].name
    vector_public_ip = yandex_compute_instance.vm["vector"].network_interface[0].nat_ip_address

    lighthouse_name      = yandex_compute_instance.vm["lighthouse"].name
    lighthouse_public_ip = yandex_compute_instance.vm["lighthouse"].network_interface[0].nat_ip_address
  })
}
