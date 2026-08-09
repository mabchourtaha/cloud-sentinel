output "instance_id" {
  value = aws_instance.app.id
}

output "public_ip" {
  description = "For testing the API and SSH access"
  value       = aws_instance.app.public_ip
}

output "security_group_id" {
  value = aws_security_group.app_sg.id
}
