output "zone_id" {
  value       = data.cloudflare_zone.this.id
  description = "Resolved Cloudflare zone ID."
}

output "tunnel_id" {
  value       = module.tunnel.tunnel_id
  description = "Tunnel UUID for DNS and debugging."
}

output "tunnel_cname_target" {
  value       = "${module.tunnel.tunnel_id}.cfargotunnel.com"
  description = "CNAME target created by the dns module."
}

output "dns_record_ids" {
  value       = module.dns.record_ids
  description = "IDs of apex, www, and api records."
}
