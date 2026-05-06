
resource "aws_iam_policy" "stuffed_toy_relay_codepipeline_exec" {
  name        = "stuffed-toy-relay-codepipeline-exec-policy-${var.env_value_environment}"
  description = ""
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:logs:ap-northeast-1:${var.account_id}:log-group:/aws/codebuild/stuffed-toy-relay-${var.env_value_environment}-build-project:*"
        ]
      },
      {
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetBucketVersioning",
          "s3:PutObjectAcl",
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
        Action = [
          "codedeploy:BatchGetDeploymentGroups",
          "codedeploy:ListApplications",
          "codedeploy:ListDeploymentGroups",
          "codedeploy:CreateDeployment",
          "codedeploy:GetApplication",
          "codedeploy:GetApplicationRevision",
          "codedeploy:GetDeployment",
          "codedeploy:GetDeploymentConfig",
          "codedeploy:RegisterApplicationRevision",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecs:DescribeServices",
          "ecs:DescribeTaskDefinition",
          "ecs:DescribeTasks",
          "ecs:ListTasks",
          "ecs:RegisterTaskDefinition",
          "ecs:UpdateService",
          "ecs:ListClusters",
          "ecs:ListServices",
          "ecs:TagResource"
        ]
        Effect   = "Allow"
        Resource = ["*"]
      },
      {
        Action   = ["elasticloadbalancing:*"]
        Effect   = "Allow"
        Resource = ["*"]
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
      },
    ]
  })
}
