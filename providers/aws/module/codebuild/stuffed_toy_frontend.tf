# 静的フロントエンドの build + S3 sync + CloudFront invalidation
# buildspec.yml が要求する env 変数:
#   - ENVIRONMENT
#   - FRONTEND_BUCKET
#   - DISTRIBUTION_ID
#   - NEXT_PUBLIC_REALTIME_RELAY_URL（ブラウザ→relay の WebSocket 接続先）
#   - NEXT_PUBLIC_RELAY_TICKET_URL（ブラウザ→relay のチケット発行 HTTP 先）

resource "aws_codebuild_project" "stuffed_toy_frontend" {
  name         = "stuffed-toy-frontend-${var.env_value_environment}-build-project"
  description  = "Build frontend static files and deploy to S3 + invalidate CloudFront"
  service_role = var.stuffed_toy_frontend_codebuild_exec_aws_iam_role_arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    type                        = "ARM_CONTAINER"
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux-aarch64-standard:3.0"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = false

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
      name  = "FRONTEND_BUCKET"
      value = var.stuffed_toy_frontend_aws_s3_bucket_id
      type  = "PLAINTEXT"
    }

    environment_variable {
      name  = "DISTRIBUTION_ID"
      value = var.stuffed_toy_frontend_aws_cloudfront_distribution_id
      type  = "PLAINTEXT"
    }

    environment_variable {
      name  = "NEXT_PUBLIC_REALTIME_RELAY_URL"
      value = "wss://${var.stuffed_toy_aws_cloudfront_distribution_domain_name}/ws/realtime-transcribe"
      type  = "PLAINTEXT"
    }

    environment_variable {
      name  = "NEXT_PUBLIC_RELAY_TICKET_URL"
      value = "https://${var.stuffed_toy_aws_cloudfront_distribution_domain_name}/relay-ticket"
      type  = "PLAINTEXT"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }
}
