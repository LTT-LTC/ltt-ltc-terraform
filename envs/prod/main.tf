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
