# This file is used to generate Ansible inventory and group_vars
# No actual cloud resources are provisioned here - all infrastructure
# is managed via Ansible on existing physical servers

terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
  }
}

# Generate Ansible inventory from template
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

# Generate Ansible group_vars from template
data "template_file" "ansible_vars" {
  template = file("${path.module}/../ansible/group_vars/all.yml.tpl")

  vars = {
    tailscale_authkey         = var.tailscale_authkey
    cloudflare_tunnel_token   = var.cloudflare_tunnel_token
    sql_sa_password           = var.sql_sa_password
    rabbitmq_user             = var.rabbitmq_user
    rabbitmq_pass             = var.rabbitmq_pass
  }
}

# Write group_vars file
resource "local_file" "ansible_vars" {
  content  = data.template_file.ansible_vars.rendered
  filename = "${path.module}/../ansible/group_vars/all.yml"
}
