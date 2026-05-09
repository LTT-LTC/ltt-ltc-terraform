variable "account_id" {
  type        = string
  description = "Cloudflare account ID."
}

variable "tunnel_name" {
  type        = string
  description = "Human-readable tunnel name (e.g. ltt-ltc-prod)."
}

variable "ingress_rules" {
  type = list(object({
    hostname = optional(string)
    path     = optional(string)
    service  = string
  }))
  description = <<-EOT
    Ordered ingress rules for cloudflared. Each rule maps a public hostname (optional) to a local origin URL
    (e.g. http://ltt-ltc-nginx:80 for Docker Compose or a Kubernetes Service DNS name).
    The final rule should typically be { service = "http_status:404" } as catch-all.
  EOT
}
