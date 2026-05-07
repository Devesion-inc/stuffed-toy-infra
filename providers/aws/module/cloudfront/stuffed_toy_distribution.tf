
locals {
  stuffed_toy_aliases          = var.stuffed_toy_cloudfront_acm_arn == "" ? [] : var.stuffed_toy_aliases
  stuffed_toy_use_default_cert = var.stuffed_toy_cloudfront_acm_arn == "" ? [true] : []
  stuffed_toy_use_custom_cert  = var.stuffed_toy_cloudfront_acm_arn == "" ? [] : [var.stuffed_toy_cloudfront_acm_arn]
}

# AWS マネージドポリシー
data "aws_cloudfront_cache_policy" "caching_disabled" {
  name = "Managed-CachingDisabled"
}

data "aws_cloudfront_cache_policy" "caching_optimized" {
  name = "Managed-CachingOptimized"
}

data "aws_cloudfront_origin_request_policy" "all_viewer" {
  name = "Managed-AllViewer"
}

data "aws_cloudfront_origin_request_policy" "all_viewer_except_host_header" {
  name = "Managed-AllViewerExceptHostHeader"
}

resource "aws_cloudfront_distribution" "stuffed_toy" {
  enabled         = true
  aliases         = local.stuffed_toy_aliases
  web_acl_id      = var.stuffed_toy_app_cloudfront_aws_wafv2_web_acl_arn
  is_ipv6_enabled = true
  comment         = "stuffed-toy-cloudfront-distribution-${var.env_value_environment}"

  # ===== Origins =====

  # S3 frontend (default origin: 静的フロントエンド配信)
  origin {
    domain_name              = var.stuffed_toy_frontend_aws_s3_bucket_regional_domain_name
    origin_id                = var.stuffed_toy_frontend_aws_s3_bucket_id
    origin_access_control_id = aws_cloudfront_origin_access_control.stuffed_toy_frontend.id
  }

  # S3 app_storage (任意の素材配信用、default ではない)
  origin {
    domain_name              = var.stuffed_toy_app_storage_aws_s3_bucket_regional_domain_name
    origin_id                = var.stuffed_toy_app_storage_aws_s3_bucket_id
    origin_access_control_id = aws_cloudfront_origin_access_control.stuffed_toy_app_storage.id
  }

  # api ALB (Next.js API: REST + NDJSON streaming)
  origin {
    domain_name = var.stuffed_toy_api_load_balancer_dns_name
    origin_id   = "stuffed-toy-api-elb-${var.env_value_environment}"

    custom_header {
      name  = "X-Stuffed-Toy-Api-Custom-Header"
      value = var.stuffed_toy_api_custom_header_value
    }
    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_protocol_policy   = var.lb_https_enabled ? "https-only" : "http-only"
      origin_ssl_protocols     = ["TLSv1.2"]
      origin_keepalive_timeout = 60
      origin_read_timeout      = 60
    }
  }

  # relay ALB (WebSocket)
  origin {
    domain_name = var.stuffed_toy_relay_load_balancer_dns_name
    origin_id   = "stuffed-toy-relay-elb-${var.env_value_environment}"

    custom_header {
      name  = "X-Stuffed-Toy-Relay-Custom-Header"
      value = var.stuffed_toy_relay_custom_header_value
    }
    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_protocol_policy   = var.lb_https_enabled ? "https-only" : "http-only"
      origin_ssl_protocols     = ["TLSv1.2"]
      origin_keepalive_timeout = 60
      origin_read_timeout      = 60
    }
  }

  # ===== Behaviors =====
  # 評価順は Terraform の宣言順（最初に一致したものが採用される）

  # /healthz → relay ALB（exact match）
  ordered_cache_behavior {
    path_pattern               = "/healthz"
    allowed_methods            = ["GET", "HEAD", "OPTIONS"]
    cached_methods             = ["GET", "HEAD"]
    target_origin_id           = "stuffed-toy-relay-elb-${var.env_value_environment}"
    cache_policy_id            = data.aws_cloudfront_cache_policy.caching_disabled.id
    origin_request_policy_id   = data.aws_cloudfront_origin_request_policy.all_viewer.id
    compress                   = false
    viewer_protocol_policy     = "redirect-to-https"
    response_headers_policy_id = aws_cloudfront_response_headers_policy.stuffed_toy_security_headers.id
  }

  # /api/* → api ALB（REST + NDJSON streaming）
  ordered_cache_behavior {
    path_pattern               = "/api/*"
    allowed_methods            = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
    cached_methods             = ["GET", "HEAD", "OPTIONS"]
    target_origin_id           = "stuffed-toy-api-elb-${var.env_value_environment}"
    cache_policy_id            = data.aws_cloudfront_cache_policy.caching_disabled.id
    origin_request_policy_id   = data.aws_cloudfront_origin_request_policy.all_viewer_except_host_header.id
    compress                   = false # NDJSON streaming への影響を避ける（必要なら true に変更）
    viewer_protocol_policy     = "redirect-to-https"
    response_headers_policy_id = aws_cloudfront_response_headers_policy.stuffed_toy_security_headers.id
  }

  # /ws/* → relay ALB（WebSocket）
  ordered_cache_behavior {
    path_pattern             = "/ws/*"
    allowed_methods          = ["GET", "HEAD", "OPTIONS"]
    cached_methods           = ["GET", "HEAD"]
    target_origin_id         = "stuffed-toy-relay-elb-${var.env_value_environment}"
    cache_policy_id          = data.aws_cloudfront_cache_policy.caching_disabled.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.all_viewer.id # Sec-WebSocket-* を通すため
    compress                 = false
    viewer_protocol_policy   = "redirect-to-https"
    # WebSocket は接続中にレスポンスヘッダを書き換えると壊れる場合があるため response_headers_policy は付けない
  }

  # default → S3 frontend（静的フロントエンド配信）
  default_cache_behavior {
    allowed_methods            = ["GET", "HEAD"]
    cached_methods             = ["GET", "HEAD"]
    target_origin_id           = var.stuffed_toy_frontend_aws_s3_bucket_id
    cache_policy_id            = data.aws_cloudfront_cache_policy.caching_optimized.id
    compress                   = true
    viewer_protocol_policy     = "redirect-to-https"
    response_headers_policy_id = aws_cloudfront_response_headers_policy.stuffed_toy_security_headers.id

    # /about → /about/index.html などの URI 書き換え
    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.stuffed_toy_index_rewrite.arn
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # ===== TLS =====

  dynamic "viewer_certificate" {
    for_each = local.stuffed_toy_use_default_cert
    content {
      cloudfront_default_certificate = viewer_certificate.value
    }
  }
  dynamic "viewer_certificate" {
    for_each = local.stuffed_toy_use_custom_cert
    content {
      acm_certificate_arn            = viewer_certificate.value
      ssl_support_method             = "sni-only"
      minimum_protocol_version       = "TLSv1.2_2021"
      cloudfront_default_certificate = false
    }
  }

  tags = {
    Name = "stuffed-toy-${var.env_value_environment}"
  }
}
