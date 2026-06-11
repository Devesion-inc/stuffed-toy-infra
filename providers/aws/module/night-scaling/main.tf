# 夜間停止モジュール
# 指定された EC2 インスタンスを EventBridge スケジュールで stop/start する
# 将来的に ECS / RDS の停止/起動にも拡張可能な汎用設計

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 6.43.0"
    }
  }
}
