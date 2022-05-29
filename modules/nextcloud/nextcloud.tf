locals {
  nextcloud_db_user = "nextcloud"
  nextcloud_db_name = "nextcloud"
}

resource "random_password" "nextcloud_db_password" {
  length = 32
}

resource "random_password" "nextcloud_db_root_password" {
  length = 32
}

resource "random_password" "nextcloud_admin_password" {
  length = 32
}

resource "docker_network" "nextcloud" {
  name = "nextcloud"
}

resource "docker_volume" "nextcloud" {
  name = "nextcloud"
}

resource "docker_container" "nextcloud_fpm" {
  name    = "nextcloud-fpm"
  image   = "nextcloud:24.0.1-fpm"
  restart = "always"

  networks_advanced {
    name = docker_network.nextcloud.name
  }

  host {
    host = "host.docker.internal"
    ip   = "host-gateway"
  }

  volumes {
    container_path = "/var/www/html"
    read_only      = false
    host_path      = var.nextcloud_volume_host_path
  }

  env = [
    "MYSQL_PASSWORD=${random_password.nextcloud_db_password.result}",
    "MYSQL_USER=${local.nextcloud_db_user}",
    "MYSQL_HOST=host.docker.internal",
    "MYSQL_DATABASE=${local.nextcloud_db_name}",
    "NEXTCLOUD_ADMIN_USER=kbetanski",
    "NEXTCLOUD_ADMIN_PASSWORD=${random_password.nextcloud_admin_password.result}",
    "SMTP_HOST=${var.smtp_host}",
    "SMTP_PORT=465",
    "SMTP_SECURE=ssl",
    "SMTP_AUTHTYPE=LOGIN",
    "SMTP_NAME=${var.smtp_name}",
    "SMTP_PASSWORD=${var.smtp_password}",
    "MAIL_FROM_ADDRESS=nextcloud",
    "MAIL_DOMAIN=${var.smtp_domain}",
    "NEXTCLOUD_TRUSTED_DOMAINS=nextcloud.betanski.dev",
    "REDIS_HOST=host.docker.internal",
  ]

  lifecycle {
    ignore_changes = [
      image
    ]
  }
}

resource "null_resource" "nextcloud" {
  triggers = {
    config_sha1 = "${sha1(file("${path.module}/nextcloud.conf"))}"
  }


  provisioner "file" {
    source      = "${path.module}/nextcloud.conf"
    destination = "/mnt/ssd/nextcloud/nextcloud.conf"

    connection {
      type        = "ssh"
      host        = "betanski.dev"
      port        = 4444
      user        = "ubuntu"
      private_key = file("~/.ssh/id_ed25519")
    }
  }
}

resource "docker_container" "nextcloud_nginx" {
  name    = "nextcloud-nginx"
  image   = "nginx:stable-alpine"
  restart = "always"

  networks_advanced {
    name = docker_network.nextcloud.name
  }

  networks_advanced {
    name    = var.proxy_network
    aliases = ["nextcloud"]
  }

  volumes {
    from_container = docker_container.nextcloud_fpm.name
  }

  volumes {
    container_path = "/etc/nginx/conf.d/default.conf"
    read_only      = true
    host_path      = "/mnt/ssd/nextcloud/nextcloud.conf"
  }

  depends_on = [
    null_resource.nextcloud,
    docker_container.nextcloud_fpm,
  ]

  lifecycle {
    ignore_changes = [
      image
    ]
  }
}
