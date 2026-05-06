
output "stuffed_toy_db_aws_db_instance_identifier" {
  value = aws_db_instance.stuffed_toy_db.identifier
}

output "stuffed_toy_db_aws_db_instance_endpoint" {
  value = aws_db_instance.stuffed_toy_db.endpoint
}

output "stuffed_toy_db_aws_db_instance_address" {
  value = aws_db_instance.stuffed_toy_db.address
}

output "stuffed_toy_db_monitoring_aws_iam_role_arn" {
  value = aws_iam_role.stuffed_toy_db_monitoring.arn
}

output "stuffed_toy_db_secret_arn" {
  value = aws_secretsmanager_secret.stuffed_toy_db.arn
}
