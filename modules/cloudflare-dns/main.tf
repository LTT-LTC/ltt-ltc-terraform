locals {
  tunnel_hostname = "${var.tunnel_uuid}.cfargotunnel.com"
}

resource "cloudflare_record" "apex" {
  zone_id = var.zone_id
  name    = var.apex_record_name
  type    = "CNAME"
  content = local.tunnel_hostname
  proxied = var.proxied
  ttl     = var.proxied ? 1 : var.ttl
}

resource "cloudflare_record" "www" {
  zone_id = var.zone_id
  name    = var.www_record_name
  type    = "CNAME"
  content = local.tunnel_hostname
  proxied = var.proxied
  ttl     = var.proxied ? 1 : var.ttl
}

resource "cloudflare_record" "api" {
  zone_id = var.zone_id
  name    = var.api_record_name
  type    = "CNAME"
  content = local.tunnel_hostname
  proxied = var.proxied
  ttl     = var.proxied ? 1 : var.ttl
}
