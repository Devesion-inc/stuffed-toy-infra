
output "stuffed_toy_api_aws_ecs_service_name" {
  value = aws_ecs_service.stuffed_toy_api.name
}

output "stuffed_toy_relay_aws_ecs_service_name" {
  value = aws_ecs_service.stuffed_toy_relay.name
}
