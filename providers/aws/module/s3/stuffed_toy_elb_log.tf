
resource "aws_s3_bucket" "stuffed_toy_api_elb_log" {
  bucket = "stuffed-toy-api-elb-log-${var.env_value_environment}"
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "stuffed_toy_api_elb_log" {
  bucket = aws_s3_bucket.stuffed_toy_api_elb_log.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "stuffed_toy_api_elb_log" {
  bucket = aws_s3_bucket.stuffed_toy_api_elb_log.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "stuffed_toy_api_elb_log" {
  bucket = aws_s3_bucket.stuffed_toy_api_elb_log.id
  policy = data.aws_iam_policy_document.stuffed_toy_api_elb_log.json
}

data "aws_iam_policy_document" "stuffed_toy_api_elb_log" {
  statement {
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${var.elb_account_id}:root"
      ]
    }
    actions = [
      "s3:PutObject"
    ]
    resources = [
      "${aws_s3_bucket.stuffed_toy_api_elb_log.arn}/access_logs/*",
      "${aws_s3_bucket.stuffed_toy_api_elb_log.arn}/diff_access_logs/*"
    ]
  }
}
