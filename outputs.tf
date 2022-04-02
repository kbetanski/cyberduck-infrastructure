output "admin_password" {
  sensitive = true
  value     = random_password.nextcloud_admin_password.result
}

output "db_root_password" {
  sensitive = true
  value     = random_password.nextcloud_db_root_password.result
}
