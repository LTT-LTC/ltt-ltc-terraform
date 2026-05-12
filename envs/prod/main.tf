data "cloudflare_zone" "this" {
  name = var.zone_name
}

module "tunnel" {
  source = "../../modules/cloudflare-tunnel"

  account_id    = var.cloudflare_account_id
  tunnel_name   = var.tunnel_name
  ingress_rules = local.ingress_rules
}

module "dns" {
  source = "../../modules/cloudflare-dns"

  zone_id          = data.cloudflare_zone.this.id
  tunnel_uuid      = module.tunnel.tunnel_id
  proxied          = true
  ttl              = 1
  apex_record_name = "@"
  www_record_name  = "www"
  api_record_name  = "api"
}

# Generate Ansible inventory and group_vars
# This creates the files needed by Ansible to configure Docker Swarm

locals {
  ansible_dir = "${path.module}/../../ansible"
}

data "template_file" "ansible_inventory" {
  template = file("${local.ansible_dir}/inventory.tpl")

  vars = {
    manager_ip = var.server_1_ip
    worker_ip  = var.server_2_ip
    ssh_user   = var.ssh_user
  }
}

resource "local_file" "ansible_inventory" {
  content  = data.template_file.ansible_inventory.rendered
  filename = "${local.ansible_dir}/inventory.ini"
}

data "template_file" "ansible_vars" {
  template = file("${local.ansible_dir}/group_vars/all.yml.tpl")

  vars = {
    tailscale_authkey       = var.tailscale_authkey
    cloudflare_tunnel_token = var.cloudflare_tunnel_token
    sql_sa_password         = var.sql_sa_password
    rabbitmq_user           = var.rabbitmq_user
    rabbitmq_pass           = var.rabbitmq_pass
  }
}

resource "local_file" "ansible_vars" {
  content  = data.template_file.ansible_vars.rendered
  filename = "${local.ansible_dir}/group_vars/all.yml"
}
