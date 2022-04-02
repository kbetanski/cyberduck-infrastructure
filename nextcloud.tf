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

resource "docker_container" "nextcloud" {
  name    = "nextcloud"
  image   = "nextcloud:22.2.6"
  restart = "always"

  networks_advanced {
    name = docker_network.nextcloud.name
  }

  networks_advanced {
    name    = docker_network.caddy.name
    aliases = ["nextcloud"]
  }

  volumes {
    container_path = "/var/www/html"
    read_only      = false
    volume_name    = docker_volume.nextcloud.name
  }

  volumes {
    container_path = "/var/nextcloud"
    read_only      = false
    host_path      = "/home/ubuntu/nextcloud"
  }

  env = [
    "MYSQL_PASSWORD=${random_password.nextcloud_db_password.result}",
    "MYSQL_USER=${local.nextcloud_db_user}",
    "MYSQL_HOST=nextcloud-mariadb",
    "MYSQL_DATABASE=${local.nextcloud_db_name}",
    "NEXTCLOUD_TRUSTED_DOMAINS=nextcloud.betanski.dev",
    "NEXTCLOUD_ADMIN_USER=kbetanski",
    "NEXTCLOUD_ADMIN_PASSWORD=${random_password.nextcloud_admin_password.result}"
  ]

  depends_on = [
    docker_container.nextcloud_mariadb
  ]
}

resource "docker_container" "nextcloud_mariadb" {
  name    = "nextcloud-mariadb"
  image   = "mariadb:10.7.3"
  restart = "always"

  command = [
    "--transaction-isolation=READ-COMMITTED",
    "--binlog-format=ROW",
    "--skip-innodb-read-only-compressed"
  ]

  networks_advanced {
    name    = docker_network.nextcloud.name
    aliases = ["nextcloud-mariadb"]
  }

  volumes {
    container_path = "/var/lib/mysql"
    read_only      = false
    volume_name    = docker_volume.nextcloud_mariadb.name
  }

  env = [
    "MYSQL_ROOT_PASSWORD=${random_password.nextcloud_db_root_password.result}",
    "MYSQL_PASSWORD=${random_password.nextcloud_db_password.result}",
    "MYSQL_USER=${local.nextcloud_db_user}",
    "MYSQL_DATABASE=${local.nextcloud_db_name}",
  ]
}
