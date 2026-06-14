resource "yandex_vpc_network" "this" {
  name = "${var.project_name}-vpc"
}

resource "yandex_vpc_subnet" "this" {
  name           = "${var.project_name}-subnet-a"
  zone           = var.default_zone
  network_id     = yandex_vpc_network.this.id
  v4_cidr_blocks = [var.vpc_cidr]
}

resource "yandex_vpc_security_group" "common" {
  name        = "${var.project_name}-common-sg"
  description = "Common rules: SSH from allowed CIDR and all egress"
  network_id  = yandex_vpc_network.this.id

  ingress {
    description    = "SSH for Ansible without bastion"
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = [var.allowed_ssh_cidr]
  }

  egress {
    description    = "Allow all outbound traffic"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "clickhouse" {
  name        = "${var.project_name}-clickhouse-sg"
  description = "ClickHouse HTTP interface only from project subnet"
  network_id  = yandex_vpc_network.this.id

  ingress {
    description    = "ClickHouse HTTP from Vector and LightHouse"
    protocol       = "TCP"
    port           = 8123
    v4_cidr_blocks = [var.vpc_cidr]
  }
}

resource "yandex_vpc_security_group" "lighthouse" {
  name        = "${var.project_name}-lighthouse-sg"
  description = "Public HTTP access to LightHouse"
  network_id  = yandex_vpc_network.this.id

  ingress {
    description    = "HTTP to LightHouse"
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}
