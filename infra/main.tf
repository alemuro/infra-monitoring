variable "base_domain" {}

locals {
  project = "monitoring"
}

terraform {
  cloud {
    organization = "alemuro"
    workspaces {
      name = "infra-monitoring"
    }
  }

  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
    }
    hcloud = {
      source = "hetznercloud/hcloud"
    }
  }
}


/* Hetzner */

resource "hcloud_server" "node" {
  name        = local.project
  image       = "ubuntu-20.04"
  server_type = "cx11"
  ssh_keys    = ["howard"]
  backups     = true
}

/* Cloudflare */
data "cloudflare_zones" "aleix" {
  filter {
    name        = var.base_domain
    lookup_type = "exact"
    status      = "active"
  }
}

resource "cloudflare_record" "node" {
  zone_id = data.cloudflare_zones.aleix.zones[0].id
  name    = "${local.project}.sys.${var.base_domain}"
  value   = hcloud_server.node.ipv4_address
  type    = "A"
  ttl     = 300
  proxied = false
}
