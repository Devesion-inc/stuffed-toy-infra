
variable "env_value_environment" {}

# stop/start 対象の EC2 インスタンス ID 一覧
variable "ec2_instance_ids" {
  type    = list(string)
  default = []
}

# 停止スケジュール（UTC cron）。例: "cron(0 13 * * ? *)" = JST 22:00
variable "stop_schedule" {
  default = "cron(0 13 * * ? *)"
}

# 起動スケジュール（UTC cron）。例: "cron(0 0 * * ? *)" = JST 09:00
variable "start_schedule" {
  default = "cron(0 0 * * ? *)"
}

# EventBridge スケジュールの自動実行を有効化するか
# false なら Lambda は作成されるが自動実行はされず、aws lambda invoke で手動操作のみ
variable "scheduling_enabled" {
  default = false
}
