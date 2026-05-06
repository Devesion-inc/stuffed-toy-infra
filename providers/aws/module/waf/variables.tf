
variable env_value_environment {}

locals {
  # develop環境ではCOUNTモード、staging/production環境ではBLOCKモード
  waf_common_rule_block = var.env_value_environment != "develop"
}
