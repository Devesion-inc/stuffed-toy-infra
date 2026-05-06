
resource "aws_cloudfront_response_headers_policy" "stuffed_toy_security_headers" {
  name    = "stuffed-toy-security-headers-${var.env_value_environment}"
  comment = "Security headers policy for stuffed-toy"

  security_headers_config {
    # クリックジャッキング対策 (CWE-1021)
    frame_options {
      frame_option = "SAMEORIGIN"
      override     = true
    }

    # HSTS - HTTPS強制 (CWE-319)
    strict_transport_security {
      access_control_max_age_sec = 31536000
      include_subdomains         = true
      preload                    = true
      override                   = true
    }

    # MIME 型推測抑止
    content_type_options {
      override = true
    }

    # Referrer 制御
    referrer_policy {
      referrer_policy = "strict-origin-when-cross-origin"
      override        = true
    }
  }
}
