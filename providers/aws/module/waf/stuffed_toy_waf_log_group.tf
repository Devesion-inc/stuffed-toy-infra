
resource "aws_cloudwatch_log_group" "stuffed_toy_app_cloudfront_waf_log_group" {
  name              = "aws-waf-logs-stuffed-toy-app-cloudfront-${var.env_value_environment}"
  retention_in_days = 400
}
