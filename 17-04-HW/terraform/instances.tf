data "yandex_compute_image" "ubuntu_2204" {
  family = "ubuntu-2204-lts"
}

resource "yandex_compute_instance" "vm" {
  for_each = local.vm_names

  name        = each.value
  hostname    = each.value
  platform_id = var.vm_platform_id
  zone        = var.default_zone

  resources {
    cores         = var.vm_resources[each.key].cores
    memory        = var.vm_resources[each.key].memory
    core_fraction = var.vm_resources[each.key].core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_2204.id
      size     = var.vm_resources[each.key].disk_size
      type     = "network-hdd"
    }
  }

  scheduling_policy {
    preemptible = var.preemptible
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.this.id
    nat       = true

    security_group_ids = concat(
      [yandex_vpc_security_group.common.id],
      each.key == "clickhouse" ? [yandex_vpc_security_group.clickhouse.id] : [],
      each.key == "lighthouse" ? [yandex_vpc_security_group.lighthouse.id] : []
    )
  }

  metadata = {
    "ssh-keys"          = local.ssh_meta
    "serial-port-enable" = "1"
  }
}
