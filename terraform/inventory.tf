# Generate Ansible inventory from Terraform
data "template_file" "ansible_inventory" {
  template = file("${path.module}/../ansible/inventory.tpl")

  vars = {
    manager_ip = var.server_1_ip
    worker_ip  = var.server_2_ip
    ssh_user   = var.ssh_user
  }
}

# Write inventory file
resource "local_file" "ansible_inventory" {
  content  = data.template_file.ansible_inventory.rendered
  filename = "${path.module}/../ansible/inventory.ini"
}

# Variables for inventory
data "template_file" "ansible_vars" {
  template = file("${path.module}/../ansible/group_vars/all.yml.tpl")

  vars = {
    tailscale_authkey     = var.tailscale_authkey
    cloudflare_tunnel_token = var.cloudflare_tunnel_token
    sql_sa_password       = var.sql_sa_password
    rabbitmq_user         = var.rabbitmq_user
    rabbitmq_pass         = var.rabbitmq_pass
  }
}

# Write group vars
resource "local_file" "ansible_vars" {
  content  = data.template_file.ansible_vars.rendered
  filename = "${path.module}/../ansible/group_vars/all.yml"
}
