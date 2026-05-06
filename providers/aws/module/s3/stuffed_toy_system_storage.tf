
resource "aws_s3_bucket" "stuffed_toy_system_storage" {
  bucket = "stuffed-toy-system-storage-${var.env_value_environment}"
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "stuffed_toy_system_storage" {
  bucket = aws_s3_bucket.stuffed_toy_system_storage.id

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

resource "aws_s3_bucket_server_side_encryption_configuration" "stuffed_toy_system_storage" {
  bucket = aws_s3_bucket.stuffed_toy_system_storage.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "stuffed_toy_system_storage" {
  bucket = aws_s3_bucket.stuffed_toy_system_storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_cors_configuration" "stuffed_toy_system_storage" {
  count  = length(var.stuffed_toy_system_storage_cors_allowed_origins) > 0 ? 1 : 0
  bucket = aws_s3_bucket.stuffed_toy_system_storage.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT"]
    allowed_origins = var.stuffed_toy_system_storage_cors_allowed_origins
    expose_headers  = ["ETag"]
    max_age_seconds = 3600
  }
}

# Enable EventBridge notifications for this bucket
resource "aws_s3_bucket_notification" "stuffed_toy_system_storage" {
  bucket      = aws_s3_bucket.stuffed_toy_system_storage.id
  eventbridge = true
}

# CloudFront経由のアクセスに制限
resource "aws_s3_bucket_policy" "stuffed_toy_system_storage" {
  bucket = aws_s3_bucket.stuffed_toy_system_storage.id
  policy = data.aws_iam_policy_document.stuffed_toy_system_storage.json
}


data "aws_iam_policy_document" "stuffed_toy_system_storage" {
  # /resources/* と /tmp/resources/* への GET, POST を許可
  statement {
    sid    = "AllowCloudFrontGetPostResources"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.stuffed_toy_system_storage.arn}/resources/*",
      "${aws_s3_bucket.stuffed_toy_system_storage.arn}/tmp/resources/*"
    ]

    condition {
      test     = "StringLike"
      variable = "aws:SourceArn"
      values = ["arn:aws:cloudfront::${var.account_id}:distribution/*"]
    }
  }
}
