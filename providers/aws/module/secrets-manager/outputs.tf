
# api
output "stuffed_toy_api_secret_arn" {
  value = aws_secretsmanager_secret.stuffed_toy_api.arn
}
output "stuffed_toy_api_secret_name" {
  value = aws_secretsmanager_secret.stuffed_toy_api.name
}

# relay
output "stuffed_toy_relay_secret_arn" {
  value = aws_secretsmanager_secret.stuffed_toy_relay.arn
}
output "stuffed_toy_relay_secret_name" {
  value = aws_secretsmanager_secret.stuffed_toy_relay.name
}
