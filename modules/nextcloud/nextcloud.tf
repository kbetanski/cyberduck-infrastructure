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

resource "docker_volume" "nextcloud_mariadb" {
  name = "nextcloud_mariadb"
}

resource "docker_container" "nextcloud_fpm" {
  name    = "nextcloud-fpm"
  image   = "nextcloud:22.2.6-fpm"
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
    volume_name    = docker_volume.nextcloud.name
  }

  volumes {
    container_path = "/var/nextcloud"
    read_only      = false
    host_path      = "/mnt/ssd/nextcloud/storage"
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
    "OBJECTSTORE_S3_SSL=true",
    "OBJECTSTORE_S3_HOST=${var.s3_host}",
    "OBJECTSTORE_S3_BUCKET=${var.s3_bucket}",
    "OBJECTSTORE_S3_KEY=${var.s3_key_id}",
    "OBJECTSTORE_S3_SECRET=${var.s3_secret}",
    "OBJECTSTORE_S3_REGION=${var.s3_region}",
    "OBJECTSTORE_S3_USEPATH_STYLE=true",
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
    destination = "/home/ubuntu/nextcloud.conf"

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
    host_path      = "/home/ubuntu/nextcloud.conf"
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
