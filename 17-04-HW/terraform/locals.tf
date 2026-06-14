locals {
  ssh_meta = "${var.ssh_user}:${var.ssh_public_key}"

  vm_names = {
    clickhouse = "clickhouse-01"
    vector     = "vector-01"
    lighthouse = "lighthouse-01"
  }
}
