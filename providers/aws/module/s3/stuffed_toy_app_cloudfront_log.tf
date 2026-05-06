
resource "aws_s3_bucket" "stuffed_toy_app_cloudfront_log" {
  bucket = "stuffed-toy-app-cloudfront-log-${var.env_value_environment}"
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "stuffed_toy_app_cloudfront_log" {
  bucket = aws_s3_bucket.stuffed_toy_app_cloudfront_log.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "stuffed_toy_app_cloudfront_log" {
  bucket = aws_s3_bucket.stuffed_toy_app_cloudfront_log.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# CloudFrontログの自動削除（400日後）
resource "aws_s3_bucket_lifecycle_configuration" "stuffed_toy_app_cloudfront_log" {
  bucket = aws_s3_bucket.stuffed_toy_app_cloudfront_log.id

  rule {
    id     = "expire-cloudfront-logs"
    status = "Enabled"

    expiration {
      days = 400
    }

    filter {
      prefix = ""
    }
  }
}

resource "aws_s3_bucket_policy" "stuffed_toy_app_cloudfront_log" {
  bucket = aws_s3_bucket.stuffed_toy_app_cloudfront_log.id
  policy = data.aws_iam_policy_document.stuffed_toy_app_cloudfront_log.json
}

# CloudFront標準ログv2用バケットポリシー
# CloudWatch Logs Delivery サービスからの書き込みを許可
data "aws_iam_policy_document" "stuffed_toy_app_cloudfront_log" {
  statement {
    sid    = "AWSLogDeliveryWrite"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
    actions = [
      "s3:PutObject"
    ]
    resources = [
      "${aws_s3_bucket.stuffed_toy_app_cloudfront_log.arn}/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [var.account_id]
    }
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
}
