# relay: GitHub branch -> CodeBuild build -> (production: Manual_Approval) -> CodeDeploy ECS
# DB マイグレーションが無いので Migrate ステージは無し

resource "aws_codepipeline" "stuffed_toy_relay" {
  name     = "stuffed-toy-relay-codepipeline-${var.env_value_environment}"
  role_arn = var.stuffed_toy_relay_codepipeline_exec_aws_iam_role_arn

  pipeline_type = "V2"

  trigger {
    provider_type = "CodeStarSourceConnection"
    git_configuration {
      source_action_name = "Source"
      push {
        branches {
          includes = [var.env_value_environment]
        }
      }
    }
  }

  artifact_store {
    type     = "S3"
    location = var.stuffed_toy_codepipeline_s3_bucket_id
  }

  stage {
    name = "Source"
    action {
      run_order        = 1
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_artifact"]

      configuration = {
        ConnectionArn        = var.codeconnection_arn
        FullRepositoryId     = var.stuffed_toy_relay_github_repository
        BranchName           = var.env_value_environment
        OutputArtifactFormat = "CODE_ZIP"
      }
    }
  }

  stage {
    name = "Build"
    action {
      run_order        = 2
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_artifact"]
      output_artifacts = ["build_artifact"]

      configuration = {
        ProjectName = var.stuffed_toy_relay_codebuild_project_name
        EnvironmentVariables = jsonencode([
          {
            type  = "PLAINTEXT"
            name  = "SUBNET_IDS"
            value = join(",", sort(var.stuffed_toy_relay_ecs_subnet_ids))
          },
          {
            type  = "PLAINTEXT"
            name  = "SECURITY_GROUP_IDS"
            value = join(",", var.stuffed_toy_relay_ecs_security_groups)
          },
        ])
      }
    }
  }

  # production のみ手動承認
  dynamic "stage" {
    for_each = var.env_value_environment == "production" ? [1] : []
    content {
      name = "Manual_Approval"
      action {
        name     = "Manual_Approval"
        category = "Approval"
        owner    = "AWS"
        provider = "Manual"
        version  = "1"
      }
    }
  }

  stage {
    name = "Deploy"
    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeployToECS"
      version         = "1"
      input_artifacts = ["build_artifact"]

      configuration = {
        ApplicationName                = var.stuffed_toy_relay_aws_codedeploy_app_name
        DeploymentGroupName            = var.stuffed_toy_relay_aws_codedeploy_deployment_group_name
        TaskDefinitionTemplateArtifact = "build_artifact"
        TaskDefinitionTemplatePath     = "task_definition.json"
        AppSpecTemplateArtifact        = "build_artifact"
        AppSpecTemplatePath            = "appspec.yaml"
      }
    }
  }
}

resource "aws_codestarnotifications_notification_rule" "stuffed_toy_relay" {
  name = "stuffed-toy-relay-codepipeline-notification-${var.env_value_environment}"

  detail_type = "FULL"

  event_type_ids = [
    "codepipeline-pipeline-pipeline-execution-started",
    "codepipeline-pipeline-pipeline-execution-failed",
    "codepipeline-pipeline-pipeline-execution-succeeded"
  ]

  resource = aws_codepipeline.stuffed_toy_relay.arn

  target {
    type    = "SNS"
    address = var.stuffed_toy_relay_build_aws_sns_topic_arn
  }
}
