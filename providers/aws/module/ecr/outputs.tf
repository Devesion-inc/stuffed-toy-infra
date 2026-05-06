
# bun (base image mirror)
output "stuffed_toy_bun_aws_ecr_repository_arn" {
  value = aws_ecr_repository.stuffed_toy_bun.arn
}
output "stuffed_toy_bun_aws_ecr_repository_url" {
  value = aws_ecr_repository.stuffed_toy_bun.repository_url
}
output "stuffed_toy_bun_aws_ecr_repository_name" {
  value = aws_ecr_repository.stuffed_toy_bun.name
}

# node (base image mirror)
output "stuffed_toy_node_aws_ecr_repository_arn" {
  value = aws_ecr_repository.stuffed_toy_node.arn
}
output "stuffed_toy_node_aws_ecr_repository_url" {
  value = aws_ecr_repository.stuffed_toy_node.repository_url
}
output "stuffed_toy_node_aws_ecr_repository_name" {
  value = aws_ecr_repository.stuffed_toy_node.name
}

# api (app)
output "stuffed_toy_api_aws_ecr_repository_arn" {
  value = aws_ecr_repository.stuffed_toy_api.arn
}
output "stuffed_toy_api_aws_ecr_repository_url" {
  value = aws_ecr_repository.stuffed_toy_api.repository_url
}
output "stuffed_toy_api_aws_ecr_repository_name" {
  value = aws_ecr_repository.stuffed_toy_api.name
}

# relay (app)
output "stuffed_toy_relay_aws_ecr_repository_arn" {
  value = aws_ecr_repository.stuffed_toy_relay.arn
}
output "stuffed_toy_relay_aws_ecr_repository_url" {
  value = aws_ecr_repository.stuffed_toy_relay.repository_url
}
output "stuffed_toy_relay_aws_ecr_repository_name" {
  value = aws_ecr_repository.stuffed_toy_relay.name
}
