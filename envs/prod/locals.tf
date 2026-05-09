locals {
  ingress_rules = [
    {
      hostname = var.public_hostnames.api
      service  = var.origin_api_url
    },
    {
      hostname = var.public_hostnames.apex
      service  = var.origin_web_url
    },
    {
      hostname = var.public_hostnames.www
      service  = var.origin_web_url
    },
    {
      service = "http_status:404"
    },
  ]
}
