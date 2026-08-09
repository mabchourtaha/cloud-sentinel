output "instance_profile_name" {
  value = aws_iam_instance_profile.app_profile.name
}

output "role_arn" {
  value = aws_iam_role.app_role.arn
}
