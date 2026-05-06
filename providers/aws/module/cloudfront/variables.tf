
variable "env_value_environment" {}

# us-east-1 の ACM 証明書 ARN（CloudFront 用）。空なら CloudFront デフォルト証明書。
variable "stuffed_toy_cloudfront_acm_arn" {
  default = ""
}
variable "stuffed_toy_aliases" {
  type    = list(string)
  default = []
}

# WAF v2 Web ACL（us-east-1, scope=CLOUDFRONT）
variable "stuffed_toy_app_cloudfront_aws_wafv2_web_acl_arn" {}

# S3 (app_storage) - CloudFront のデフォルトオリジン
variable "stuffed_toy_app_storage_aws_s3_bucket_id" {}
variable "stuffed_toy_app_storage_aws_s3_bucket_regional_domain_name" {}

# api ALB
variable "stuffed_toy_api_load_balancer_dns_name" {}
variable "stuffed_toy_api_custom_header_value" {}

# relay ALB
variable "stuffed_toy_relay_load_balancer_dns_name" {}
variable "stuffed_toy_relay_custom_header_value" {}

# CloudFront アクセスログ v2 用 S3
variable "stuffed_toy_app_cloudfront_log_aws_s3_bucket_arn" {}

# ALB が HTTPS なら true（origin_protocol_policy が https-only に切り替わる）
variable "lb_https_enabled" {
  default = false
}
