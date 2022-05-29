output "pihole_password" {
  sensitive = true
  value     = random_password.pihole_password.result
}
