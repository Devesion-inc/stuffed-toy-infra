# =====================================================================
# ベース image mirror（Docker Hub の oven/bun / library/node を社内 ECR に複製）
# =====================================================================
# 目的: Docker Hub レート制限の回避 + サプライチェーン強化
# 運用: CI / 手動で `docker pull → tag → push` してミラーを更新する
# Lifecycle policy は付けない（任意のバージョンを長期保持するため）

resource "aws_ecr_repository" "stuffed_toy_bun" {
  name                 = "stuffed-toy-bun-${var.env_value_environment}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
  encryption_configuration {
    encryption_type = "AES256"
  }
}

resource "aws_ecr_repository" "stuffed_toy_node" {
  name                 = "stuffed-toy-node-${var.env_value_environment}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
  encryption_configuration {
    encryption_type = "AES256"
  }
}

# =====================================================================
# アプリケーション image
# =====================================================================
# CI（CodeBuild）でビルドした image を push する

resource "aws_ecr_repository" "stuffed_toy_api" {
  name                 = "stuffed-toy-api-${var.env_value_environment}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
  encryption_configuration {
    encryption_type = "AES256"
  }
}

resource "aws_ecr_repository" "stuffed_toy_relay" {
  name                 = "stuffed-toy-relay-${var.env_value_environment}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
  encryption_configuration {
    encryption_type = "AES256"
  }
}

resource "aws_ecr_repository" "stuffed_toy_tts" {
  name                 = "stuffed-toy-tts-${var.env_value_environment}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
  encryption_configuration {
    encryption_type = "AES256"
  }
}

# 古いアプリ image を自動削除（直近 30 個保持）。コスト抑制。
# ベース image は対象外（特定バージョンを長期保持するため）。

resource "aws_ecr_lifecycle_policy" "stuffed_toy_api" {
  repository = aws_ecr_repository.stuffed_toy_api.name
  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 30 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 30
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

resource "aws_ecr_lifecycle_policy" "stuffed_toy_relay" {
  repository = aws_ecr_repository.stuffed_toy_relay.name
  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 30 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 30
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# TTS image は大きい（CUDA + .aivmx）ので少なめに保持
resource "aws_ecr_lifecycle_policy" "stuffed_toy_tts" {
  repository = aws_ecr_repository.stuffed_toy_tts.name
  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 5 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 5
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
