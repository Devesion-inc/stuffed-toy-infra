
resource "aws_s3_bucket" "stuffed_toy_build" {
  bucket = "stuffed-toy-build-${var.env_value_environment}"
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "stuffed_toy_build" {
  bucket = aws_s3_bucket.stuffed_toy_build.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "stuffed_toy_build" {
  bucket = aws_s3_bucket.stuffed_toy_build.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
