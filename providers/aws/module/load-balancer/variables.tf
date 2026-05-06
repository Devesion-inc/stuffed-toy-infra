
variable "env_value_environment" {}
variable "subnet_ids" {}

variable "stuffed_toy_custom_header_value" {}
variable "stuffed_toy_loadbalancer_security_groups" {}

variable "stuffed_toy_api_blue_aws_lb_target_group_arn" {}
variable "stuffed_toy_api_green_aws_lb_target_group_arn" {}

variable "stuffed_toy_api_elb_log_aws_s3_bucket_id" {}

variable "stuffed_toy_acm_arn" {
  default = ""
}
