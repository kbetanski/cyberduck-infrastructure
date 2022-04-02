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

provider "null" {}
