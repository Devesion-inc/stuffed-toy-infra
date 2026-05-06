
module "stuffed_toy_s3_bucket" {
  source = "../../module/s3"

  env_value_environment = var.env_value_environment
  account_id            = var.account_id
  elb_account_id        = var.elb_account_id
}

module "stuffed_toy_waf" {
  source = "../../module/waf"

  env_value_environment = var.env_value_environment

  providers = {
    aws = aws.virginia
  }
}

module "stuffed_toy_security_group" {
  source = "../../module/security-group"

  env_value_environment = var.env_value_environment
  vpc_id                = var.vpc_id
  lb_https_enabled      = var.stuffed_toy_acm_arn != ""
}

module "stuffed_toy_vpc_endpoint" {
  source = "../../module/vpc-endpoint"

  env_value_environment                     = var.env_value_environment
  vpc_id                                    = var.vpc_id
  aws_region                                = var.aws_region
  private_subnet_ids                        = var.private_subnet_ids
  secretsmanager_endpoint_security_group_id = module.stuffed_toy_security_group.stuffed_toy_secretsmanager_endpoint_aws_security_group_id
}

module "stuffed_toy_target_group" {
  source = "../../module/target-group"

  env_value_environment = var.env_value_environment
  vpc_id                = var.vpc_id
}

module "stuffed_toy_lb" {
  source = "../../module/load-balancer"

  env_value_environment           = var.env_value_environment
  subnet_ids                      = var.public_subnet_ids
  stuffed_toy_custom_header_value = var.stuffed_toy_custom_header_value
  stuffed_toy_loadbalancer_security_groups = [
    module.stuffed_toy_security_group.stuffed_toy_api_loadbalancer_main_aws_security_group_id, module.stuffed_toy_security_group.stuffed_toy_api_loadbalancer_sub_aws_security_group_id
  ]
  stuffed_toy_api_blue_aws_lb_target_group_arn  = module.stuffed_toy_target_group.stuffed_toy_api_blue_aws_lb_target_group_arn
  stuffed_toy_api_green_aws_lb_target_group_arn = module.stuffed_toy_target_group.stuffed_toy_api_green_aws_lb_target_group_arn
  stuffed_toy_api_elb_log_aws_s3_bucket_id      = module.stuffed_toy_s3_bucket.stuffed_toy_api_elb_log_aws_s3_bucket_id
  stuffed_toy_acm_arn                           = var.stuffed_toy_acm_arn
}
