resource "random_password" "pihole_password" {
  length = 32
}

resource "docker_container" "pihole" {
  name    = "pihole"
  image   = "pihole/pihole:latest"
  restart = "unless-stopped"

  networks_advanced {
    name    = var.proxy_network
    aliases = ["pihole"]
  }

  env = [
    "VIRTUAL_HOST=pihole.betanski.dev",
    "TZ=Europe/Warsaw",
    "WEBPASSWORD=${random_password.pihole_password.result}",
  ]

  ports {
    internal = 53
    external = 53
    protocol = "tcp"
  }

  ports {
    internal = 53
    external = 53
    protocol = "udp"
  }

  volumes {
    container_path = "/etc/pihole"
    host_path      = "/mnt/ssd/pihole/etc"
    read_only      = false
  }

  volumes {
    container_path = "/etc/dns-masq.d"
    host_path      = "/etc/pihole/dnsmasq.d"
    read_only      = false
  }

  lifecycle {
    ignore_changes = [
      image
    ]
  }
}
