# Prisma migrate deploy を ECS run-task で実行する CodeBuild

resource "aws_codebuild_project" "stuffed_toy_api_migrate" {
  name         = "stuffed-toy-api-migrate-${var.env_value_environment}-build-project"
  service_role = var.stuffed_toy_api_migrate_codebuild_exec_aws_iam_role_arn

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec_migrate.yml"
  }

  source_version = var.env_value_environment

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    type            = "ARM_CONTAINER"
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/amazonlinux-aarch64-standard:3.0"
    privileged_mode = false

    environment_variable {
      name  = "ENVIRONMENT"
      value = var.env_value_environment
      type  = "PLAINTEXT"
    }

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = var.account_id
      type  = "PLAINTEXT"
    }

    environment_variable {
      name  = "CLUSTER_NAME"
      value = "stuffed-toy-${var.env_value_environment}"
      type  = "PLAINTEXT"
    }
  }
}
