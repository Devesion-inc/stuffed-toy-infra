
variable "env_value_environment" {}
variable "codeconnection_arn" {}

# 共通: build artifact 用 S3
variable "stuffed_toy_codepipeline_s3_bucket_id" {}

# api
variable "stuffed_toy_api_codepipeline_exec_aws_iam_role_arn" {}
variable "stuffed_toy_api_github_repository" {}
variable "stuffed_toy_api_codebuild_project_name" {}
variable "stuffed_toy_api_migrate_codebuild_project_name" {}
variable "stuffed_toy_api_build_aws_sns_topic_arn" {}
variable "stuffed_toy_api_ecs_subnet_ids" {}
variable "stuffed_toy_api_ecs_security_groups" {}
variable "stuffed_toy_api_aws_codedeploy_app_name" {}
variable "stuffed_toy_api_aws_codedeploy_deployment_group_name" {}

# relay
variable "stuffed_toy_relay_codepipeline_exec_aws_iam_role_arn" {}
variable "stuffed_toy_relay_github_repository" {}
variable "stuffed_toy_relay_codebuild_project_name" {}
variable "stuffed_toy_relay_build_aws_sns_topic_arn" {}
variable "stuffed_toy_relay_ecs_subnet_ids" {}
variable "stuffed_toy_relay_ecs_security_groups" {}
variable "stuffed_toy_relay_aws_codedeploy_app_name" {}
variable "stuffed_toy_relay_aws_codedeploy_deployment_group_name" {}

# frontend
variable "stuffed_toy_frontend_codepipeline_exec_aws_iam_role_arn" {}
variable "stuffed_toy_frontend_github_repository" {}
variable "stuffed_toy_frontend_codebuild_project_name" {}
variable "stuffed_toy_frontend_build_aws_sns_topic_arn" {}
