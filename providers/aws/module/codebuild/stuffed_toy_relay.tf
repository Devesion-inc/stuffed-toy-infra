
resource "aws_codebuild_project" "stuffed_toy_relay" {
  name         = "stuffed-toy-relay-${var.env_value_environment}-build-project"
  service_role = var.stuffed_toy_relay_codebuild_exec_aws_iam_role_arn

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }

  source_version = var.env_value_environment

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    type            = "ARM_CONTAINER"
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/amazonlinux-aarch64-standard:3.0"
    privileged_mode = true

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
  }

  cache {
    type  = "LOCAL"
    modes = ["LOCAL_DOCKER_LAYER_CACHE"]
  }
}
