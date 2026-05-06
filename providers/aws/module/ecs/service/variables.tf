
variable "env_value_environment" {}
variable "subnet_ids" {}

# api
variable "stuffed_toy_api_aws_ecs_task_definition_arn" {}
variable "stuffed_toy_api_aws_ecs_cluster_id" {}
variable "stuffed_toy_api_aws_ecs_cluster_name" {}
variable "stuffed_toy_api_blue_aws_lb_target_group_arn" {}
variable "stuffed_toy_api_ecs_security_groups" {}
variable "stuffed_toy_api_ecs_min_capacity" {
  default = 1
}
variable "stuffed_toy_api_ecs_max_capacity" {
  default = 3
}

# relay
variable "stuffed_toy_relay_aws_ecs_task_definition_arn" {}
variable "stuffed_toy_relay_aws_ecs_cluster_id" {}
variable "stuffed_toy_relay_aws_ecs_cluster_name" {}
variable "stuffed_toy_relay_blue_aws_lb_target_group_arn" {}
variable "stuffed_toy_relay_ecs_security_groups" {}
variable "stuffed_toy_relay_ecs_min_capacity" {
  default = 1
}
variable "stuffed_toy_relay_ecs_max_capacity" {
  default = 3
}
