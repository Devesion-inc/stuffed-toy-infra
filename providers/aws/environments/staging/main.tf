
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

  env_value_environment = var.env_value_environment
  subnet_ids            = var.public_subnet_ids

  # api
  stuffed_toy_api_custom_header_value = var.stuffed_toy_api_custom_header_value
  stuffed_toy_api_loadbalancer_security_groups = [
    module.stuffed_toy_security_group.stuffed_toy_api_loadbalancer_main_aws_security_group_id,
    module.stuffed_toy_security_group.stuffed_toy_api_loadbalancer_sub_aws_security_group_id,
  ]
  stuffed_toy_api_blue_aws_lb_target_group_arn  = module.stuffed_toy_target_group.stuffed_toy_api_blue_aws_lb_target_group_arn
  stuffed_toy_api_green_aws_lb_target_group_arn = module.stuffed_toy_target_group.stuffed_toy_api_green_aws_lb_target_group_arn

  # relay
  stuffed_toy_relay_custom_header_value = var.stuffed_toy_relay_custom_header_value
  stuffed_toy_relay_loadbalancer_security_groups = [
    module.stuffed_toy_security_group.stuffed_toy_relay_loadbalancer_main_aws_security_group_id,
    module.stuffed_toy_security_group.stuffed_toy_relay_loadbalancer_sub_aws_security_group_id,
  ]
  stuffed_toy_relay_blue_aws_lb_target_group_arn  = module.stuffed_toy_target_group.stuffed_toy_relay_blue_aws_lb_target_group_arn
  stuffed_toy_relay_green_aws_lb_target_group_arn = module.stuffed_toy_target_group.stuffed_toy_relay_green_aws_lb_target_group_arn

  # shared
  stuffed_toy_api_elb_log_aws_s3_bucket_id = module.stuffed_toy_s3_bucket.stuffed_toy_api_elb_log_aws_s3_bucket_id
  stuffed_toy_acm_arn                      = var.stuffed_toy_acm_arn
}

module "stuffed_toy_iam_policy" {
  source = "../../module/iam/policy"

  env_value_environment = var.env_value_environment
  account_id            = var.account_id
}

module "stuffed_toy_iam_role" {
  source = "../../module/iam/role"

  env_value_environment = var.env_value_environment

  # api
  stuffed_toy_api_codebuild_exec_aws_iam_policy_arn    = module.stuffed_toy_iam_policy.stuffed_toy_api_codebuild_exec_aws_iam_policy_arn
  stuffed_toy_api_codedeploy_exec_aws_iam_policy_arn   = module.stuffed_toy_iam_policy.stuffed_toy_api_codedeploy_exec_aws_iam_policy_arn
  stuffed_toy_api_codepipeline_exec_aws_iam_policy_arn = module.stuffed_toy_iam_policy.stuffed_toy_api_codepipeline_exec_aws_iam_policy_arn
  stuffed_toy_api_ecs_exec_aws_iam_policy_arn          = module.stuffed_toy_iam_policy.stuffed_toy_api_ecs_exec_aws_iam_policy_arn
  stuffed_toy_api_ecs_task_aws_iam_policy_arn          = module.stuffed_toy_iam_policy.stuffed_toy_api_ecs_task_aws_iam_policy_arn

  # relay
  stuffed_toy_relay_codebuild_exec_aws_iam_policy_arn    = module.stuffed_toy_iam_policy.stuffed_toy_relay_codebuild_exec_aws_iam_policy_arn
  stuffed_toy_relay_codedeploy_exec_aws_iam_policy_arn   = module.stuffed_toy_iam_policy.stuffed_toy_relay_codedeploy_exec_aws_iam_policy_arn
  stuffed_toy_relay_codepipeline_exec_aws_iam_policy_arn = module.stuffed_toy_iam_policy.stuffed_toy_relay_codepipeline_exec_aws_iam_policy_arn
  stuffed_toy_relay_ecs_exec_aws_iam_policy_arn          = module.stuffed_toy_iam_policy.stuffed_toy_relay_ecs_exec_aws_iam_policy_arn
  stuffed_toy_relay_ecs_task_aws_iam_policy_arn          = module.stuffed_toy_iam_policy.stuffed_toy_relay_ecs_task_aws_iam_policy_arn

  # frontend
  stuffed_toy_frontend_codebuild_exec_aws_iam_policy_arn    = module.stuffed_toy_iam_policy.stuffed_toy_frontend_codebuild_exec_aws_iam_policy_arn
  stuffed_toy_frontend_codepipeline_exec_aws_iam_policy_arn = module.stuffed_toy_iam_policy.stuffed_toy_frontend_codepipeline_exec_aws_iam_policy_arn
}

module "stuffed_toy_cloudfront" {
  source = "../../module/cloudfront"

  env_value_environment = var.env_value_environment

  stuffed_toy_cloudfront_acm_arn = var.stuffed_toy_cloudfront_acm_arn
  stuffed_toy_aliases            = var.stuffed_toy_aliases
  lb_https_enabled               = var.stuffed_toy_acm_arn != ""

  stuffed_toy_app_cloudfront_aws_wafv2_web_acl_arn = module.stuffed_toy_waf.stuffed_toy_app_cloudfront_aws_wafv2_web_acl_arn

  stuffed_toy_app_storage_aws_s3_bucket_id                   = module.stuffed_toy_s3_bucket.stuffed_toy_app_storage_aws_s3_bucket_id
  stuffed_toy_app_storage_aws_s3_bucket_regional_domain_name = module.stuffed_toy_s3_bucket.stuffed_toy_app_storage_aws_s3_bucket_regional_domain_name
  stuffed_toy_frontend_aws_s3_bucket_id                      = module.stuffed_toy_s3_bucket.stuffed_toy_frontend_aws_s3_bucket_id
  stuffed_toy_frontend_aws_s3_bucket_regional_domain_name    = module.stuffed_toy_s3_bucket.stuffed_toy_frontend_aws_s3_bucket_regional_domain_name
  stuffed_toy_app_cloudfront_log_aws_s3_bucket_arn           = module.stuffed_toy_s3_bucket.stuffed_toy_app_cloudfront_log_aws_s3_bucket_arn

  stuffed_toy_api_load_balancer_dns_name = module.stuffed_toy_lb.stuffed_toy_api_load_balancer_dns_name
  stuffed_toy_api_custom_header_value    = var.stuffed_toy_api_custom_header_value

  stuffed_toy_relay_load_balancer_dns_name = module.stuffed_toy_lb.stuffed_toy_relay_load_balancer_dns_name
  stuffed_toy_relay_custom_header_value    = var.stuffed_toy_relay_custom_header_value

  providers = {
    aws = aws.virginia
  }
}

module "stuffed_toy_rds" {
  source = "../../module/rds"

  env_value_environment              = var.env_value_environment
  subnet_ids                         = var.private_subnet_ids
  stuffed_toy_rds_security_group_ids = [module.stuffed_toy_security_group.stuffed_toy_db_aws_security_group_id]
  stuffed_toy_rds_instance_class     = var.stuffed_toy_rds_instance_class
}

module "stuffed_toy_secrets_manager" {
  source = "../../module/secrets-manager"

  env_value_environment = var.env_value_environment
}

module "stuffed_toy_ecr" {
  source = "../../module/ecr"

  env_value_environment = var.env_value_environment
}

module "stuffed_toy_ecs_cluster" {
  source = "../../module/ecs/cluster"

  env_value_environment = var.env_value_environment
}

module "stuffed_toy_sns_topic" {
  source = "../../module/sns-topic"

  env_value_environment = var.env_value_environment
  account_id            = var.account_id
}

module "stuffed_toy_tts" {
  source = "../../module/tts"

  env_value_environment = var.env_value_environment
  account_id            = var.account_id
  vpc_id                = var.vpc_id
  subnet_id             = var.public_subnet_ids[0] # 単一 AZ 配置（GPU タイプは AZ 限定が多いため）

  # ECR 経由で image pull（Docker Hub 不要）
  ecr_repository_url = module.stuffed_toy_ecr.stuffed_toy_tts_aws_ecr_repository_url
  image_tag          = var.stuffed_toy_tts_image_tag

  # api / relay の ECS SG から TTS への通信のみ許可
  allowed_security_group_ids = [
    module.stuffed_toy_security_group.stuffed_toy_api_app_ecs_main_aws_security_group_id,
    module.stuffed_toy_security_group.stuffed_toy_api_app_ecs_sub_aws_security_group_id,
    module.stuffed_toy_security_group.stuffed_toy_relay_ecs_main_aws_security_group_id,
    module.stuffed_toy_security_group.stuffed_toy_relay_ecs_sub_aws_security_group_id,
  ]

  instance_type = var.stuffed_toy_tts_instance_type
}

# 夜間停止モジュール（EC2 stop/start を Lambda + EventBridge で行う）
# 対象インスタンスを追加したい場合は ec2_instance_ids に足す
module "stuffed_toy_night_scaling" {
  source = "../../module/night-scaling"

  env_value_environment = var.env_value_environment

  ec2_instance_ids = [
    module.stuffed_toy_tts.stuffed_toy_tts_instance_id,
  ]

  # JST 12:00 起動 / JST 24:00 (= 翌 0:00) 停止
  start_schedule     = "cron(0 3 * * ? *)"  # UTC 03:00 = JST 12:00
  stop_schedule      = "cron(0 15 * * ? *)" # UTC 15:00 = JST 24:00
  scheduling_enabled = var.stuffed_toy_night_scaling_enabled
}

module "stuffed_toy_ecs_service" {
  source = "../../module/ecs/service"

  env_value_environment = var.env_value_environment
  subnet_ids            = var.public_subnet_ids

  # api
  stuffed_toy_api_aws_ecs_task_definition_arn  = var.stuffed_toy_api_aws_ecs_task_definition_arn
  stuffed_toy_api_aws_ecs_cluster_id           = module.stuffed_toy_ecs_cluster.stuffed_toy_aws_ecs_cluster_id
  stuffed_toy_api_aws_ecs_cluster_name         = module.stuffed_toy_ecs_cluster.stuffed_toy_aws_ecs_cluster_name
  stuffed_toy_api_blue_aws_lb_target_group_arn = module.stuffed_toy_target_group.stuffed_toy_api_blue_aws_lb_target_group_arn
  stuffed_toy_api_ecs_security_groups = [
    module.stuffed_toy_security_group.stuffed_toy_api_app_ecs_main_aws_security_group_id,
    module.stuffed_toy_security_group.stuffed_toy_api_app_ecs_sub_aws_security_group_id,
  ]
  stuffed_toy_api_ecs_min_capacity = var.stuffed_toy_api_ecs_min_capacity
  stuffed_toy_api_ecs_max_capacity = var.stuffed_toy_api_ecs_max_capacity

  # relay
  stuffed_toy_relay_aws_ecs_task_definition_arn  = var.stuffed_toy_relay_aws_ecs_task_definition_arn
  stuffed_toy_relay_aws_ecs_cluster_id           = module.stuffed_toy_ecs_cluster.stuffed_toy_aws_ecs_cluster_id
  stuffed_toy_relay_aws_ecs_cluster_name         = module.stuffed_toy_ecs_cluster.stuffed_toy_aws_ecs_cluster_name
  stuffed_toy_relay_blue_aws_lb_target_group_arn = module.stuffed_toy_target_group.stuffed_toy_relay_blue_aws_lb_target_group_arn
  stuffed_toy_relay_ecs_security_groups = [
    module.stuffed_toy_security_group.stuffed_toy_relay_ecs_main_aws_security_group_id,
    module.stuffed_toy_security_group.stuffed_toy_relay_ecs_sub_aws_security_group_id,
  ]
  stuffed_toy_relay_ecs_min_capacity = var.stuffed_toy_relay_ecs_min_capacity
  stuffed_toy_relay_ecs_max_capacity = var.stuffed_toy_relay_ecs_max_capacity
}

module "stuffed_toy_codebuild" {
  source = "../../module/codebuild"

  env_value_environment = var.env_value_environment
  account_id            = var.account_id

  stuffed_toy_api_codebuild_exec_aws_iam_role_arn         = module.stuffed_toy_iam_role.stuffed_toy_api_codebuild_exec_aws_iam_role_arn
  stuffed_toy_api_migrate_codebuild_exec_aws_iam_role_arn = module.stuffed_toy_iam_role.stuffed_toy_api_codebuild_exec_aws_iam_role_arn
  stuffed_toy_relay_codebuild_exec_aws_iam_role_arn       = module.stuffed_toy_iam_role.stuffed_toy_relay_codebuild_exec_aws_iam_role_arn

  # frontend
  stuffed_toy_frontend_codebuild_exec_aws_iam_role_arn = module.stuffed_toy_iam_role.stuffed_toy_frontend_codebuild_exec_aws_iam_role_arn
  stuffed_toy_frontend_aws_s3_bucket_id                = module.stuffed_toy_s3_bucket.stuffed_toy_frontend_aws_s3_bucket_id
  stuffed_toy_frontend_aws_cloudfront_distribution_id  = module.stuffed_toy_cloudfront.stuffed_toy_aws_cloudfront_distribution_id
  stuffed_toy_aws_cloudfront_distribution_domain_name  = module.stuffed_toy_cloudfront.stuffed_toy_aws_cloudfront_distribution_domain_name
}

module "stuffed_toy_codedeploy" {
  source = "../../module/codedeploy"

  env_value_environment = var.env_value_environment

  # api
  stuffed_toy_api_codedeploy_exec_aws_iam_role_arn = module.stuffed_toy_iam_role.stuffed_toy_api_codedeploy_exec_aws_iam_role_arn
  stuffed_toy_api_ecs_cluster_name                 = module.stuffed_toy_ecs_cluster.stuffed_toy_aws_ecs_cluster_name
  stuffed_toy_api_ecs_service_name                 = module.stuffed_toy_ecs_service.stuffed_toy_api_aws_ecs_service_name
  stuffed_toy_api_lb_listener_main_arn             = module.stuffed_toy_lb.stuffed_toy_api_main_aws_lb_listener_arn
  stuffed_toy_api_lb_listener_sub_arn              = module.stuffed_toy_lb.stuffed_toy_api_sub_aws_lb_listener_arn
  stuffed_toy_api_blue_target_group_name           = module.stuffed_toy_target_group.stuffed_toy_api_blue_aws_lb_target_group_name
  stuffed_toy_api_green_target_group_name          = module.stuffed_toy_target_group.stuffed_toy_api_green_aws_lb_target_group_name

  # relay
  stuffed_toy_relay_codedeploy_exec_aws_iam_role_arn = module.stuffed_toy_iam_role.stuffed_toy_relay_codedeploy_exec_aws_iam_role_arn
  stuffed_toy_relay_ecs_cluster_name                 = module.stuffed_toy_ecs_cluster.stuffed_toy_aws_ecs_cluster_name
  stuffed_toy_relay_ecs_service_name                 = module.stuffed_toy_ecs_service.stuffed_toy_relay_aws_ecs_service_name
  stuffed_toy_relay_lb_listener_main_arn             = module.stuffed_toy_lb.stuffed_toy_relay_main_aws_lb_listener_arn
  stuffed_toy_relay_lb_listener_sub_arn              = module.stuffed_toy_lb.stuffed_toy_relay_sub_aws_lb_listener_arn
  stuffed_toy_relay_blue_target_group_name           = module.stuffed_toy_target_group.stuffed_toy_relay_blue_aws_lb_target_group_name
  stuffed_toy_relay_green_target_group_name          = module.stuffed_toy_target_group.stuffed_toy_relay_green_aws_lb_target_group_name
}

module "stuffed_toy_codepipeline" {
  source = "../../module/codepipeline"

  env_value_environment                 = var.env_value_environment
  codeconnection_arn                    = var.codeconnection_arn
  stuffed_toy_codepipeline_s3_bucket_id = module.stuffed_toy_s3_bucket.stuffed_toy_build_aws_s3_bucket_id

  # api
  stuffed_toy_api_codepipeline_exec_aws_iam_role_arn = module.stuffed_toy_iam_role.stuffed_toy_api_codepipeline_exec_aws_iam_role_arn
  stuffed_toy_api_github_repository                  = var.stuffed_toy_api_github_repository
  stuffed_toy_api_codebuild_project_name             = module.stuffed_toy_codebuild.stuffed_toy_api_codebuild_project_name
  stuffed_toy_api_migrate_codebuild_project_name     = module.stuffed_toy_codebuild.stuffed_toy_api_migrate_codebuild_project_name
  stuffed_toy_api_build_aws_sns_topic_arn            = module.stuffed_toy_sns_topic.stuffed_toy_api_build_aws_sns_topic_arn
  stuffed_toy_api_ecs_subnet_ids                     = var.public_subnet_ids
  stuffed_toy_api_ecs_security_groups = [
    module.stuffed_toy_security_group.stuffed_toy_api_app_ecs_main_aws_security_group_id,
    module.stuffed_toy_security_group.stuffed_toy_api_app_ecs_sub_aws_security_group_id,
  ]
  stuffed_toy_api_aws_codedeploy_app_name              = module.stuffed_toy_codedeploy.stuffed_toy_api_aws_codedeploy_app_name
  stuffed_toy_api_aws_codedeploy_deployment_group_name = module.stuffed_toy_codedeploy.stuffed_toy_api_aws_codedeploy_deployment_group_name

  # relay
  stuffed_toy_relay_codepipeline_exec_aws_iam_role_arn = module.stuffed_toy_iam_role.stuffed_toy_relay_codepipeline_exec_aws_iam_role_arn
  stuffed_toy_relay_github_repository                  = var.stuffed_toy_relay_github_repository
  stuffed_toy_relay_codebuild_project_name             = module.stuffed_toy_codebuild.stuffed_toy_relay_codebuild_project_name
  stuffed_toy_relay_build_aws_sns_topic_arn            = module.stuffed_toy_sns_topic.stuffed_toy_relay_build_aws_sns_topic_arn
  stuffed_toy_relay_ecs_subnet_ids                     = var.public_subnet_ids
  stuffed_toy_relay_ecs_security_groups = [
    module.stuffed_toy_security_group.stuffed_toy_relay_ecs_main_aws_security_group_id,
    module.stuffed_toy_security_group.stuffed_toy_relay_ecs_sub_aws_security_group_id,
  ]
  stuffed_toy_relay_aws_codedeploy_app_name              = module.stuffed_toy_codedeploy.stuffed_toy_relay_aws_codedeploy_app_name
  stuffed_toy_relay_aws_codedeploy_deployment_group_name = module.stuffed_toy_codedeploy.stuffed_toy_relay_aws_codedeploy_deployment_group_name

  # frontend
  stuffed_toy_frontend_codepipeline_exec_aws_iam_role_arn = module.stuffed_toy_iam_role.stuffed_toy_frontend_codepipeline_exec_aws_iam_role_arn
  stuffed_toy_frontend_github_repository                  = var.stuffed_toy_frontend_github_repository
  stuffed_toy_frontend_codebuild_project_name             = module.stuffed_toy_codebuild.stuffed_toy_frontend_codebuild_project_name
  stuffed_toy_frontend_build_aws_sns_topic_arn            = module.stuffed_toy_sns_topic.stuffed_toy_frontend_build_aws_sns_topic_arn
}
