
account_id     = "364046406916"
elb_account_id = "582318560864"
aws_region     = "ap-northeast-1"
aws_profile    = "stuffed-toy-local-deployer-staging"

# タグに利用する変数
env_value_environment           = "staging"
tag_project                     = "stuffed-toy"
tag_cm_cost_billing_group_key   = "CmBillingGroup"
tag_cm_cost_billing_group_value = "stuffed-toy-staging"

# vpc
vpc_id = "vpc-09005a9be2e89d16b"

public_subnet_ids = [
  "subnet-09a94541db1cb5445",
  "subnet-018acfadb8772389f",
  "subnet-047d7bd96b7784ecd"
]
private_subnet_ids = [
  "subnet-0939ee55f3e5eb79a",
  "subnet-0389a14513bb4048e",
  "subnet-0fe6dc787f96fded1"
]

# load balancer
stuffed_toy_api_custom_header_value   = "65wKHnB4E31G"
stuffed_toy_relay_custom_header_value = "Ir4JXslYDuTu"
stuffed_toy_acm_arn                   = "" # 空文字なら HTTP (80/8080)、ARN を入れると HTTPS (443/8443) に切り替わる

# cloudfront
stuffed_toy_cloudfront_acm_arn = "" # us-east-1 の ACM 証明書 ARN（空ならデフォルト証明書）
stuffed_toy_aliases            = [] # CloudFront の代替ドメイン名（ACM 設定時のみ使用）

# rds
stuffed_toy_rds_instance_class = "db.t4g.micro"

# ecs service
stuffed_toy_api_aws_ecs_task_definition_arn   = "arn:aws:ecs:ap-northeast-1:364046406916:task-definition/stuffed-toy-api-staging:1"
stuffed_toy_relay_aws_ecs_task_definition_arn = "arn:aws:ecs:ap-northeast-1:364046406916:task-definition/stuffed-toy-relay-staging:1"
stuffed_toy_api_ecs_min_capacity              = 1
stuffed_toy_api_ecs_max_capacity              = 1
stuffed_toy_relay_ecs_min_capacity            = 1
stuffed_toy_relay_ecs_max_capacity            = 1

# codepipeline
codeconnection_arn                  = "arn:aws:codeconnections:us-east-1:364046406916:connection/16f8cf77-b40a-45ec-976d-9cd34687472e"
stuffed_toy_api_github_repository   = "Devesion-inc/stuffed-toy-api"
stuffed_toy_relay_github_repository = "Devesion-inc/stuffed-toy-relay"
