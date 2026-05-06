
resource "aws_s3_bucket" "stuffed_toy_app_storage" {
  bucket = "stuffed-toy-app-storage-${var.env_value_environment}"
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "stuffed_toy_app_storage" {
  bucket = aws_s3_bucket.stuffed_toy_app_storage.id

  rule {
    id     = "delete-tmp-files-after-1-day"
    status = "Enabled"

    filter {
      prefix = "tmp/"
    }

    expiration {
      days = 1
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "stuffed_toy_app_storage" {
  bucket = aws_s3_bucket.stuffed_toy_app_storage.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "stuffed_toy_app_storage" {
  bucket = aws_s3_bucket.stuffed_toy_app_storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# CloudFront経由のアクセスに制限
resource "aws_s3_bucket_policy" "stuffed_toy_app_storage" {
  bucket = aws_s3_bucket.stuffed_toy_app_storage.id
  policy = data.aws_iam_policy_document.stuffed_toy_app_storage.json
}


data "aws_iam_policy_document" "stuffed_toy_app_storage" {
  statement {
    sid    = "AllowCloudFrontServicePrincipal"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.stuffed_toy_app_storage.arn}/*"
    ]

    condition {
      test     = "StringLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:cloudfront::${var.account_id}:distribution/*"]
    }
  }
}
