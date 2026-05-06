# CloudFront 標準ログ v2 設定
# Source (CloudFront distribution) → Destination (S3 bucket) → Delivery で連結

resource "aws_cloudwatch_log_delivery_source" "stuffed_toy_cloudfront" {
  name         = "stuffed-toy-cloudfront-${var.env_value_environment}"
  log_type     = "ACCESS_LOGS"
  resource_arn = aws_cloudfront_distribution.stuffed_toy.arn
}

resource "aws_cloudwatch_log_delivery_destination" "stuffed_toy_cloudfront_s3" {
  name          = "stuffed-toy-cloudfront-s3-${var.env_value_environment}"
  output_format = "parquet" # Athena で読みやすい形式

  delivery_destination_configuration {
    destination_resource_arn = var.stuffed_toy_app_cloudfront_log_aws_s3_bucket_arn
  }
}

resource "aws_cloudwatch_log_delivery" "stuffed_toy_cloudfront_to_s3" {
  delivery_source_name     = aws_cloudwatch_log_delivery_source.stuffed_toy_cloudfront.name
  delivery_destination_arn = aws_cloudwatch_log_delivery_destination.stuffed_toy_cloudfront_s3.arn

  record_fields = [
    "date",
    "time",
    "timestamp(ms)",
    "x-edge-location",
    "x-edge-request-id",
    "x-edge-result-type",
    "x-edge-response-result-type",
    "x-edge-detailed-result-type",
    "c-ip",
    "c-port",
    "c-country",
    "asn",
    "cs-method",
    "cs-protocol",
    "cs-protocol-version",
    "cs-uri-stem",
    "cs-uri-query",
    "cs-bytes",
    "cs(Host)",
    "cs(Referer)",
    "cs(User-Agent)",
    "cs(Cookie)",
    "sc-status",
    "sc-bytes",
    "sc-content-type",
    "sc-content-len",
    "sc-range-start",
    "sc-range-end",
    "time-taken",
    "time-to-first-byte",
    "origin-fbl",
    "origin-lbl",
    "ssl-protocol",
    "ssl-cipher",
    "x-host-header",
    "x-forwarded-for",
    "fle-status",
    "fle-encrypted-fields",
    "cache-behavior-path-pattern",
    "timestamp",
    "distributionid",
    "distribution-tenant-id",
    "connection-id"
  ]

  s3_delivery_configuration {
    enable_hive_compatible_path = false
    suffix_path                 = "AWSLogs/{accountid}/{distributionid}/{yyyy}/{MM}/{dd}/{HH}"
  }
}
