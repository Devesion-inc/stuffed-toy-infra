# 静的フロントエンド配信用 S3 バケット
# CloudFront OAC 経由でのみアクセス可能

resource "aws_s3_bucket" "stuffed_toy_frontend" {
  bucket = "stuffed-toy-frontend-${var.env_value_environment}"
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "stuffed_toy_frontend" {
  bucket = aws_s3_bucket.stuffed_toy_frontend.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "stuffed_toy_frontend" {
  bucket                  = aws_s3_bucket.stuffed_toy_frontend.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# CloudFront 経由のアクセスのみ許可
resource "aws_s3_bucket_policy" "stuffed_toy_frontend" {
  bucket = aws_s3_bucket.stuffed_toy_frontend.id
  policy = data.aws_iam_policy_document.stuffed_toy_frontend.json
}

data "aws_iam_policy_document" "stuffed_toy_frontend" {
  statement {
    sid    = "AllowCloudFrontServicePrincipal"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    actions = ["s3:GetObject"]
    resources = [
      "${aws_s3_bucket.stuffed_toy_frontend.arn}/*"
    ]
    condition {
      test     = "StringLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:cloudfront::${var.account_id}:distribution/*"]
    }
  }
}
