
variable "env_value_environment" {}
variable "subnet_ids" {}
variable "stuffed_toy_rds_security_group_ids" {}

# DB 設定（標準 PostgreSQL）
variable "stuffed_toy_rds_engine" {
  default = "postgres"
}
variable "stuffed_toy_rds_engine_version" {
  default = "17.4"
}
variable "stuffed_toy_rds_name" {
  default = "stuffed_toy"
}
variable "stuffed_toy_rds_username" {
  default = "stuffed_toy_admin"
}
variable "stuffed_toy_rds_instance_class" {
  default = "db.t4g.micro"
}
variable "stuffed_toy_rds_sslmode" {
  default = "require"
}
