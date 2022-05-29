output "nextcloud_db_root_password" {
  sensitive = true
  value     = module.nextcloud.db_root_password
}

output "nextcloud_admin_password" {
  sensitive = true
  value     = module.nextcloud.admin_password
}

output "pihole_password" {
  sensitive = true
  value     = module.pihole.pihole_password
}
