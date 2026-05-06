
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
stuffed_toy_custom_header_value = "65wKHnB4E31G"
stuffed_toy_acm_arn             = "" # 空文字なら HTTP (80/8080)、ARN を入れると HTTPS (443/8443) に切り替わる
