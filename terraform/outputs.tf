output "db_password" {
  value     = aws_db_instance.db_instance.password
  sensitive = true
}

output "bastion_ip" {
  value = aws_instance.bastion.public_ip
}
