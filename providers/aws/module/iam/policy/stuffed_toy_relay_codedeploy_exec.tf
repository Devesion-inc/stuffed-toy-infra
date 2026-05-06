
resource "aws_iam_policy" "stuffed_toy_relay_codedeploy_exec" {
  name        = "stuffed-toy-relay-codedeploy-exec-policy-${var.env_value_environment}"
  description = ""
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecs:DescribeServices",
          "ecs:CreateTaskSet",
          "ecs:UpdateServicePrimaryTaskSet",
          "ecs:DeleteTaskSet",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:DescribeListeners",
          "elasticloadbalancing:ModifyListener",
          "elasticloadbalancing:DescribeRules",
          "elasticloadbalancing:ModifyRule"
        ]
        Effect   = "Allow"
        Resource = ["*"]
      },
      {
        Action = [
          "lambda:InvokeFunction",
          "cloudwatch:DescribeAlarms",
          "sns:Publish"
        ]
        Effect   = "Allow"
        Resource = ["*"]
      },
      {
        Action = [
          "ssm:GetParameters",
          "secretsmanager:GetSecretValue",
        ]
        Effect   = "Allow"
        Resource = ["*"]
      },
      {
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:s3:::stuffed-toy-build-${var.env_value_environment}/*"
        ]
      },
      {
        Effect   = "Allow"
        Action   = ["iam:PassRole"]
        Resource = ["*"]
        Condition = {
          StringLike = {
            "iam:PassedToService" = "ecs-tasks.amazonaws.com"
          }
        }
      }
    ]
  })
}
