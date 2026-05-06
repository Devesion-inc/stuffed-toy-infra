
variable "env_value_environment" {}
variable "subnet_ids" {}
variable "stuffed_toy_rds_security_group_ids" {}

# DB 設定
variable "stuffed_toy_rds_engine" {
  default = "aurora-postgresql"
}
variable "stuffed_toy_rds_engine_version" {
  default = "17.9"
}
variable "stuffed_toy_rds_name" {
  default = "stuffed_toy"
}
variable "stuffed_toy_rds_username" {
  default = "stuffed_toy_admin"
}
variable "stuffed_toy_rds_availability_zones" {
  type = list(string)
}
variable "stuffed_toy_rds_instance_class" {
  default = "db.t4g.medium"
}
variable "stuffed_toy_rds_reader_capacity_min" {
  default = 0
}
variable "stuffed_toy_rds_reader_capacity_max" {
  default = 0
}
variable "stuffed_toy_rds_sslmode" {
  default = "require"
}
