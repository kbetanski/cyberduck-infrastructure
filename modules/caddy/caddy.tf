resource "docker_volume" "caddy" {
  name = "caddy"
}

resource "docker_network" "caddy" {
  name = "caddy"
}

resource "null_resource" "caddy" {
  triggers = {
    config_sha1 = "${sha1(file("${path.module}/Caddyfile"))}"
  }


  provisioner "file" {
    source      = "${path.module}/Caddyfile"
    destination = "/mnt/ssd/Caddyfile"

    connection {
      type        = "ssh"
      host        = "betanski.dev"
      port        = 4444
      user        = "ubuntu"
      private_key = file("~/.ssh/id_ed25519")
    }
  }

}

resource "docker_container" "caddy" {
  name    = "caddy"
  image   = "caddy:2-alpine"
  restart = "always"

  networks_advanced {
    name = docker_network.caddy.name
  }

  ports {
    internal = 80
    external = 80
  }

  ports {
    internal = 443
    external = 443
  }

  volumes {
    container_path = "/data"
    read_only      = false
    volume_name    = docker_volume.caddy.name
  }

  volumes {
    container_path = "/public"
    read_only      = true
    host_path      = "/mnt/ssd/web/public"
  }

  volumes {
    container_path = "/etc/caddy/Caddyfile"
    read_only      = true
    host_path      = "/mnt/ssd/Caddyfile"
  }

  lifecycle {
    ignore_changes = [
      image
    ]
  }
}
