# frontend 静的サイト: GitHub branch -> CodeBuild (build + S3 sync + invalidation)
# Deploy ステージは無し（buildspec 内で完結）

resource "aws_codepipeline" "stuffed_toy_frontend" {
  name     = "stuffed-toy-frontend-codepipeline-${var.env_value_environment}"
  role_arn = var.stuffed_toy_frontend_codepipeline_exec_aws_iam_role_arn

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
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = var.codeconnection_arn
        FullRepositoryId = var.stuffed_toy_frontend_github_repository
        BranchName       = var.env_value_environment
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

  # Build ステージ内で S3 sync と CloudFront invalidation を実行
  stage {
    name = "Deploy"
    action {
      name            = "Deploy"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source_output"]

      configuration = {
        ProjectName = var.stuffed_toy_frontend_codebuild_project_name
      }
    }
  }
}

resource "aws_codestarnotifications_notification_rule" "stuffed_toy_frontend" {
  name = "stuffed-toy-frontend-codepipeline-notification-${var.env_value_environment}"

  detail_type = "FULL"

  event_type_ids = [
    "codepipeline-pipeline-pipeline-execution-started",
    "codepipeline-pipeline-pipeline-execution-failed",
    "codepipeline-pipeline-pipeline-execution-succeeded"
  ]

  resource = aws_codepipeline.stuffed_toy_frontend.arn

  target {
    type    = "SNS"
    address = var.stuffed_toy_frontend_build_aws_sns_topic_arn
  }
}
