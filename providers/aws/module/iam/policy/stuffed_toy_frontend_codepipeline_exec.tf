
resource "aws_iam_policy" "stuffed_toy_frontend_codepipeline_exec" {
  name        = "stuffed-toy-frontend-codepipeline-exec-policy-${var.env_value_environment}"
  description = ""
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetBucketVersioning",
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:s3:::stuffed-toy-build-${var.env_value_environment}/*"
        ]
      },
      {
        Action = [
          "codebuild:BatchGetProjects",
          "codebuild:CreateProject",
          "codebuild:ListCuratedEnvironmentImages",
          "codebuild:ListProjects",
          "codebuild:StartBuild",
          "codebuild:BatchGetBuilds",
        ]
        Effect   = "Allow"
        Resource = ["*"]
      },
      {
        Action   = ["codestar-connections:UseConnection"]
        Resource = ["*"]
        Effect   = "Allow"
      },
      {
        Action = [
          "ssm:GetParameters",
          "secretsmanager:GetSecretValue",
        ]
        Effect   = "Allow"
        Resource = ["*"]
      }
    ]
  })
}
