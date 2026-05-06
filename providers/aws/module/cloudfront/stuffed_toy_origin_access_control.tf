
resource "aws_cloudfront_origin_access_control" "stuffed_toy_app_storage" {
  name                              = "stuffed-toy-app-storage-oac-${var.env_value_environment}"
  description                       = "stuffed-toy app storage S3 origin access control"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}
