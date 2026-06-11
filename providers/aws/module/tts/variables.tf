
variable "env_value_environment" {}
variable "account_id" {}
variable "vpc_id" {}

# 配置先サブネット（public 1個。ECR/SSM への outbound 用に public IP を付与）
variable "subnet_id" {}

# ECR リポジトリ URL（例: 364046406916.dkr.ecr.ap-northeast-1.amazonaws.com/stuffed-toy-tts-staging）
variable "ecr_repository_url" {}

# 引くタグ
variable "image_tag" {
  default = "latest"
}

# インスタンスタイプ（GPU 必須）
variable "instance_type" {
  default = "g4dn.xlarge" # NVIDIA T4 16GB / $0.526/h（オンデマンド）
}

# 起動 EBS サイズ
# Deep Learning AMI のスナップショットは 75GB 以上を要求するため、100GB で余裕を持たせる
variable "root_volume_size" {
  default = 100
}

# api / relay の ECS SG（ingress 許可元）
variable "allowed_security_group_ids" {
  type = list(string)
}

# 公開ポート（aivis engine のデフォルト）
variable "container_port" {
  default = 10101
}
