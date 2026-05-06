
# api
output "stuffed_toy_api_loadbalancer_main_aws_security_group_id" {
  value = aws_security_group.stuffed_toy_api_loadbalancer_main.id
}
output "stuffed_toy_api_loadbalancer_sub_aws_security_group_id" {
  value = aws_security_group.stuffed_toy_api_loadbalancer_sub.id
}
output "stuffed_toy_api_app_ecs_main_aws_security_group_id" {
  value = aws_security_group.stuffed_toy_api_app_ecs_main.id
}
output "stuffed_toy_api_app_ecs_sub_aws_security_group_id" {
  value = aws_security_group.stuffed_toy_api_app_ecs_sub.id
}

# relay
output "stuffed_toy_relay_loadbalancer_main_aws_security_group_id" {
  value = aws_security_group.stuffed_toy_relay_loadbalancer_main.id
}
output "stuffed_toy_relay_loadbalancer_sub_aws_security_group_id" {
  value = aws_security_group.stuffed_toy_relay_loadbalancer_sub.id
}
output "stuffed_toy_relay_ecs_main_aws_security_group_id" {
  value = aws_security_group.stuffed_toy_relay_ecs_main.id
}
output "stuffed_toy_relay_ecs_sub_aws_security_group_id" {
  value = aws_security_group.stuffed_toy_relay_ecs_sub.id
}

# rds
output "stuffed_toy_db_aws_security_group_id" {
  value = aws_security_group.stuffed_toy_db.id
}

# vpc endpoint
output "stuffed_toy_secretsmanager_endpoint_aws_security_group_id" {
  value = aws_security_group.stuffed_toy_secretsmanager_endpoint.id
}
