
variable "env_value_environment" {}

# stop/start 対象の EC2 インスタンス ID 一覧
variable "ec2_instance_ids" {
  type    = list(string)
  default = []
}

# スケジュールのタイムゾーン（EventBridge Scheduler がネイティブ対応）
variable "schedule_timezone" {
  default = "Asia/Tokyo"
}

# 停止スケジュール（schedule_timezone のローカル時刻 cron）。例: "cron(0 22 * * ? *)" = JST 22:00
variable "stop_schedule" {
  default = "cron(0 22 * * ? *)"
}

# 起動スケジュール（schedule_timezone のローカル時刻 cron）。例: "cron(0 9 * * ? *)" = JST 09:00
variable "start_schedule" {
  default = "cron(0 9 * * ? *)"
}

# EventBridge スケジュールの自動実行を有効化するか
# false なら Lambda は作成されるが自動実行はされず、aws lambda invoke で手動操作のみ
variable "scheduling_enabled" {
  default = false
}
