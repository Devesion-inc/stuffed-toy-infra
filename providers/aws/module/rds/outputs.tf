
output "stuffed_toy_db_aws_rds_cluster_identifier" {
  value = aws_rds_cluster.stuffed_toy_db.cluster_identifier
}

output "stuffed_toy_db_aws_rds_cluster_endpoint" {
  value = aws_rds_cluster.stuffed_toy_db.endpoint
}

output "stuffed_toy_db_aws_rds_cluster_reader_endpoint" {
  value = aws_rds_cluster.stuffed_toy_db.reader_endpoint
}

output "stuffed_toy_db_aws_rds_cluster_instance_identifier" {
  value = aws_rds_cluster_instance.stuffed_toy_db.identifier
}

output "stuffed_toy_db_monitoring_aws_iam_role_arn" {
  value = aws_iam_role.stuffed_toy_db_monitoring.arn
}

output "stuffed_toy_db_secret_arn" {
  value = aws_secretsmanager_secret.stuffed_toy_db.arn
}
