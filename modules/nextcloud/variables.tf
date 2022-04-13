variable "nextcloud_volume_host_path" {
  default = "/mnt/ssd/nextcloud/html"
  type    = string
}

variable "proxy_network" {
  type = string
}

variable "smtp_host" {
  type = string
}

variable "smtp_name" {
  type = string
}

variable "smtp_password" {
  type = string
}

variable "smtp_domain" {
  type = string
}
