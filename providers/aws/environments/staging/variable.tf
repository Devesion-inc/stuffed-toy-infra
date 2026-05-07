
variable "account_id" {}
variable "elb_account_id" {}
variable "aws_profile" {}
variable "aws_region" {}

# common
variable "env_value_environment" {}
variable "tag_project" {}
variable "tag_cm_cost_billing_group_key" {}
variable "tag_cm_cost_billing_group_value" {}

# vpc
variable "vpc_id" {}
variable "public_subnet_ids" {}
variable "private_subnet_ids" {}

# load balancer
variable "stuffed_toy_api_custom_header_value" {}
variable "stuffed_toy_relay_custom_header_value" {}
variable "stuffed_toy_acm_arn" {}

# cloudfront
variable "stuffed_toy_cloudfront_acm_arn" {
  default = ""
}
variable "stuffed_toy_aliases" {
  type    = list(string)
  default = []
}

# rds
variable "stuffed_toy_rds_instance_class" {}

# ecs service
variable "stuffed_toy_api_aws_ecs_task_definition_arn" {}
variable "stuffed_toy_api_ecs_min_capacity" {
  default = 1
}
variable "stuffed_toy_api_ecs_max_capacity" {
  default = 3
}
variable "stuffed_toy_relay_aws_ecs_task_definition_arn" {}
variable "stuffed_toy_relay_ecs_min_capacity" {
  default = 1
}
variable "stuffed_toy_relay_ecs_max_capacity" {
  default = 3
}

# codepipeline
variable "codeconnection_arn" {}
variable "stuffed_toy_api_github_repository" {}
variable "stuffed_toy_relay_github_repository" {}
variable "stuffed_toy_frontend_github_repository" {}
