output "tunnel_hostname" {
  description = "CNAME target pointing at the Cloudflare Tunnel."
  value       = local.tunnel_hostname
}

output "record_ids" {
  description = "Created DNS record IDs."
  value = {
    apex = cloudflare_record.apex.id
    www  = cloudflare_record.www.id
    api  = cloudflare_record.api.id
  }
}
