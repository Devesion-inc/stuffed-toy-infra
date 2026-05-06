
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
