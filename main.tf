terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "3.1.2"
    }

    null = {
      source  = "hashicorp/null"
      version = "3.1.1"
    }

    docker = {
      source  = "kreuzwerker/docker"
      version = "2.16.0"
    }
  }
}

provider "random" {}

provider "docker" {
  host = "ssh://ubuntu@betanski.dev:4444"
}

module "caddy" {
  source = "./modules/caddy"
}

module "nextcloud" {
  source = "./modules/nextcloud"

  proxy_network = module.caddy.caddy_network
  smtp_domain   = var.smtp_domain
  smtp_host     = var.smtp_host
  smtp_name     = var.smtp_name
  smtp_password = var.smtp_password

  depends_on = [
    module.caddy
  ]
}

module "pihole" {
  source = "./modules/pihole"

  proxy_network = module.caddy.caddy_network
}
