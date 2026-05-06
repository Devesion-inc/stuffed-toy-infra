
resource "aws_wafv2_web_acl" "stuffed_toy_app_cloudfront" {
  name        = "stuffed-toy-app-cloudfront-waf-acl-${var.env_value_environment}"
  description = "stuffed-toy app cloudfront waf-acl for terraform"
  scope       = "CLOUDFRONT"

  default_action {
    allow {}
  }

  rule {
    name     = "AWSManagedRulesAmazonIpReputationList"
    priority = 30

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesAmazonIpReputationListMetric"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 10

    dynamic "override_action" {
      for_each = local.waf_common_rule_block ? [1] : []
      content {
        none {}
      }
    }

    dynamic "override_action" {
      for_each = local.waf_common_rule_block ? [] : [1]
      content {
        count {}
      }
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"

        rule_action_override {
          action_to_use {
            count {}
          }
          name = "NoUserAgent_HEADER"
        }

        rule_action_override {
          action_to_use {
            count {}
          }
          name = "SizeRestrictions_BODY"
        }

        rule_action_override {
          action_to_use {
            count {}
          }
          name = "GenericLFI_BODY"
        }

        rule_action_override {
          action_to_use {
            count {}
          }
          name = "CrossSiteScripting_BODY"
        }

        rule_action_override {
          action_to_use {
            count {}
          }
          name = "EC2MetaDataSSRF_BODY"
        }

        rule_action_override {
          action_to_use {
            count {}
          }
          name = "GenericRFI_BODY"
        }
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesCommonRuleSetMetric"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesKnownBadInputsRuleSet"
    priority = 20

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesKnownBadInputsRuleSetMetric"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesSQLiRuleSet"
    priority = 50

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesSQLiRuleSetMetric"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AppSizeRestrictionsBody"
    priority = 5

    action {
      block {}
    }

    statement {
      size_constraint_statement {
        comparison_operator = "GT"
        size                = 104857600 # 100MB
        field_to_match {
          body {
            oversize_handling = "NO_MATCH"
          }
        }
        text_transformation {
          priority = 0
          type     = "NONE"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AppSizeRestrictionsBodyMetric"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSRateBasedRule"
    priority = 1

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit                 = 1000
        aggregate_key_type    = "IP"
        evaluation_window_sec = 60
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSRateBasedRuleMetric"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "TerraformWebACLMetric"
    sampled_requests_enabled   = false
  }
}

resource "aws_wafv2_web_acl_logging_configuration" "stuffed_toy_app_cloudfront" {
  resource_arn            = aws_wafv2_web_acl.stuffed_toy_app_cloudfront.arn
  log_destination_configs = [aws_cloudwatch_log_group.stuffed_toy_app_cloudfront_waf_log_group.arn]

  logging_filter {
    default_behavior = "DROP"

    filter {
      behavior    = "KEEP"
      requirement = "MEETS_ANY"

      condition {
        action_condition {
          action = "BLOCK"
        }
      }

      condition {
        action_condition {
          action = "COUNT"
        }
      }
    }
  }
}
