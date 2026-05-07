
resource "aws_iam_policy" "stuffed_toy_frontend_codebuild_exec" {
  name        = "stuffed-toy-frontend-codebuild-exec-policy-${var.env_value_environment}"
  description = ""
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject"
        ]
        Resource = [
          "arn:aws:s3:::stuffed-toy-build-${var.env_value_environment}/*"
        ]
      },
      {
        # フロントエンド配信用バケットへの sync 権限
        Effect = "Allow"
        Action = [
          "s3:DeleteObject",
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:ListBucket",
          "s3:PutObject",
          "s3:PutObjectAcl"
        ]
        Resource = [
          "arn:aws:s3:::stuffed-toy-frontend-${var.env_value_environment}",
          "arn:aws:s3:::stuffed-toy-frontend-${var.env_value_environment}/*"
        ]
      },
      {
        # CloudFront cache invalidation
        Effect = "Allow"
        Action = [
          "cloudfront:CreateInvalidation"
        ]
        Resource = [
          "arn:aws:cloudfront::${var.account_id}:distribution/*"
        ]
      }
    ]
  })
}
