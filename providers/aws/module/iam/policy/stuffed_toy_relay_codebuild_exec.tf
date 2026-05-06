
resource "aws_iam_policy" "stuffed_toy_relay_codebuild_exec" {
  name        = "stuffed-toy-relay-codebuild-exec-policy-${var.env_value_environment}"
  description = ""
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["ecr:GetAuthorizationToken"]
        Effect   = "Allow"
        Resource = ["*"]
      },
      {
        Action   = ["ecr:*"]
        Effect   = "Allow"
        Resource = ["*"]
      },
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:logs:ap-northeast-1:${var.account_id}:log-group:/aws/codebuild/stuffed-toy-relay-${var.env_value_environment}-build-project",
          "arn:aws:logs:ap-northeast-1:${var.account_id}:log-group:/aws/codebuild/stuffed-toy-relay-${var.env_value_environment}-build-project:*"
        ]
      },
      {
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetBucketAcl",
          "s3:GetBucketLocation"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:s3:::stuffed-toy-build-${var.env_value_environment}/*"
        ]
      },
      {
        Action = [
          "codebuild:CreateReportGroup",
          "codebuild:CreateReport",
          "codebuild:UpdateReport",
          "codebuild:BatchPutTestCases",
          "codebuild:BatchPutCodeCoverages"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:codebuild:ap-northeast-1:${var.account_id}:report-group/stuffed-toy-relay-${var.env_value_environment}-build-project"
        ]
      },
      {
        Sid    = "SidCodeStarConnections"
        Effect = "Allow"
        Resource = [
          "arn:aws:codestar-connections:ap-northeast-1:${var.account_id}:connection*",
          "arn:aws:codeconnections:ap-northeast-1:${var.account_id}:connection*"
        ],
        Action = [
          "codestar-connections:GetConnectionToken",
          "codestar-connections:GetConnection",
          "codeconnections:GetConnectionToken",
          "codeconnections:GetConnection",
          "codeconnections:UseConnection"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ecs:RegisterTaskDefinition",
          "ecs:TagResource",
          "ecs:DescribeTaskDefinition",
          "ecs:ListTasks",
          "ecs:DescribeTasks",
          "ecs:RunTask",
          "ecs:Wait"
        ]
        Resource = ["*"]
      },
      {
        Effect = "Allow"
        Action = ["iam:PassRole"]
        Resource = [
          "arn:aws:iam::${var.account_id}:role/stuffed-toy-relay-ecs-task-role-${var.env_value_environment}",
          "arn:aws:iam::${var.account_id}:role/stuffed-toy-relay-ecs-exec-role-${var.env_value_environment}"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = [
          "arn:aws:secretsmanager:ap-northeast-1:${var.account_id}:secret:/stuffed-toy/${var.env_value_environment}/relay*"
        ]
      },
    ]
  })
}
