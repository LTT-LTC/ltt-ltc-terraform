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
  description = "Local HTTP origin for apex + www (Docker Swarm with Traefik: http://traefik:80)."
  default     = "http://traefik:80"
}

variable "origin_api_url" {
  type        = string
  description = "Local HTTP origin for api host (Docker Swarm with Traefik: http://traefik:80)."
  default     = "http://traefik:80"
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

# Server Configuration
variable "server_1_ip" {
  type        = string
  description = "Tailscale IP of Server 1 (smaller, runs FE/Gateway/Redis/Traefik/Cloudflared)"
  default     = "100.99.158.16"
}

variable "server_2_ip" {
  type        = string
  description = "Tailscale IP of Server 2 (stronger, runs Databases/.NET services)"
  default     = "100.109.240.84"
}

variable "ssh_user" {
  type        = string
  description = "SSH user for server access"
  default     = "ubuntu"
}

# Secrets for Ansible
variable "tailscale_authkey" {
  type        = string
  description = "Tailscale auth key for server join (one-time key)"
  sensitive   = true
}

variable "cloudflare_tunnel_token" {
  type        = string
  description = "Cloudflare tunnel token for cloudflared"
  sensitive   = true
}

variable "sql_sa_password" {
  type        = string
  description = "SQL Server SA password"
  sensitive   = true
  default     = "MyPassword123."
}

variable "rabbitmq_user" {
  type        = string
  description = "RabbitMQ default user"
  default     = "guest"
}

variable "rabbitmq_pass" {
  type        = string
  description = "RabbitMQ default password"
  sensitive   = true
  default     = "guest"
}
