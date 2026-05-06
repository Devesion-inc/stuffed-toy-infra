# RDS Enhanced Monitoring + 監査ログ配信用の IAM Role
# AWS マネージドポリシー AmazonRDSEnhancedMonitoringRole を attach するだけで両方をカバーできる

resource "aws_iam_role" "stuffed_toy_db_monitoring" {
  name = "stuffed-toy-db-monitoring-role-${var.env_value_environment}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "stuffed_toy_db_monitoring" {
  role       = aws_iam_role.stuffed_toy_db_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}
