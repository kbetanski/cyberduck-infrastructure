terraform {
  required_providers {
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
