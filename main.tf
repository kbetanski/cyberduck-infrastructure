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
  s3_bucket     = var.s3_bucket
  s3_host       = var.s3_host
  s3_key_id     = var.s3_key_id
  s3_region     = var.s3_region
  s3_secret     = var.s3_secret
  smtp_domain   = var.smtp_domain
  smtp_host     = var.smtp_host
  smtp_name     = var.smtp_name
  smtp_password = var.smtp_password

  depends_on = [
    module.caddy
  ]
}
