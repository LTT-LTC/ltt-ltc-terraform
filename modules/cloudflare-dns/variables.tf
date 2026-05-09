variable "zone_id" {
  type        = string
  description = "Cloudflare zone ID for DNS records."
}

variable "tunnel_uuid" {
  type        = string
  description = "Cloudflare Tunnel UUID (from tunnel resource). CNAME target becomes \"<uuid>.cfargotunnel.com\"."
}

variable "apex_record_name" {
  type        = string
  description = "DNS record name for apex (use \"@\" for zone root)."
  default     = "@"
}

variable "www_record_name" {
  type        = string
  description = "Relative hostname for www (e.g. www)."
  default     = "www"
}

variable "api_record_name" {
  type        = string
  description = "Relative hostname for API (e.g. api)."
  default     = "api"
}

variable "proxied" {
  type        = bool
  description = "Orange-cloud proxy (recommended for tunnel)."
  default     = true
}

variable "ttl" {
  type        = number
  description = "TTL (1 = automatic when proxied)."
  default     = 1
}
