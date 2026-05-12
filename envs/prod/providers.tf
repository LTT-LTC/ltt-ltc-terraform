provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

provider "local" {
  # Local provider for generating Ansible files
}
