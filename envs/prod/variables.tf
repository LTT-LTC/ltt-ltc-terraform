variable "cloudflare_api_token" {
  type        = string
  description = "Cloudflare API token (use TF_VAR_cloudflare_api_token or terraform.tfvars — never commit)."
  sensitive   = true
}

variable "cloudflare_account_id" {
  type        = string
  description = "Cloudflare account ID (Dashboard → Account Home)."
}

variable "zone_name" {
  type        = string
  description = "DNS zone name managed in Cloudflare (e.g. ltt-ltc.io.vn)."
  default     = "ltt-ltc.io.vn"
}

variable "tunnel_name" {
  type        = string
  description = "Cloudflare Tunnel name."
  default     = "ltt-ltc-prod"
}

variable "origin_web_url" {
  type        = string
  description = "Local HTTP origin for apex + www (Docker: http://ltt-ltc-nginx:80; K8s: e.g. http://ingress-nginx-controller.ltt-ltc.svc.cluster.local:80)."
  default     = "http://ltt-ltc-nginx:80"
}

variable "origin_api_url" {
  type        = string
  description = "Local HTTP origin for api host (often same nginx virtual hosts as compose)."
  default     = "http://ltt-ltc-nginx:80"
}

variable "public_hostnames" {
  type = object({
    apex = string
    www  = string
    api  = string
  })
  description = "FQDNs matching TLS/host routing on your ingress (must exist as tunnel ingress hostnames)."
  default = {
    apex = "ltt-ltc.io.vn"
    www  = "www.ltt-ltc.io.vn"
    api  = "api.ltt-ltc.io.vn"
  }
}
