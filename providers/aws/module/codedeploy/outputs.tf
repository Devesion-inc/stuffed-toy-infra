
output "stuffed_toy_api_aws_codedeploy_app_name" {
  value = aws_codedeploy_app.stuffed_toy_api.name
}

output "stuffed_toy_api_aws_codedeploy_deployment_group_name" {
  value = aws_codedeploy_deployment_group.stuffed_toy_api.deployment_group_name
}

output "stuffed_toy_relay_aws_codedeploy_app_name" {
  value = aws_codedeploy_app.stuffed_toy_relay.name
}

output "stuffed_toy_relay_aws_codedeploy_deployment_group_name" {
  value = aws_codedeploy_deployment_group.stuffed_toy_relay.deployment_group_name
}
