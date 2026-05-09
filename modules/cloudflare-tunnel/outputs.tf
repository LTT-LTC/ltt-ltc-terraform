output "tunnel_id" {
  description = "Tunnel UUID (used in DNS CNAME to *.cfargotunnel.com)."
  value       = cloudflare_zero_trust_tunnel_cloudflared.this.id
}

output "tunnel_name" {
  description = "Tunnel display name."
  value       = cloudflare_zero_trust_tunnel_cloudflared.this.name
}
