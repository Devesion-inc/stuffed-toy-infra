# Athena クエリ結果保存用S3バケット

resource "aws_s3_bucket" "stuffed_toy_athena_query_results" {
  bucket = "stuffed-toy-athena-query-results-${var.env_value_environment}"
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "stuffed_toy_athena_query_results" {
  bucket = aws_s3_bucket.stuffed_toy_athena_query_results.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "stuffed_toy_athena_query_results" {
  bucket = aws_s3_bucket.stuffed_toy_athena_query_results.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# クエリ結果の自動削除（30日後）
resource "aws_s3_bucket_lifecycle_configuration" "stuffed_toy_athena_query_results" {
  bucket = aws_s3_bucket.stuffed_toy_athena_query_results.id

  rule {
    id     = "expire-query-results"
    status = "Enabled"

    expiration {
      days = 30
    }

    filter {
      prefix = ""
    }
  }
}
