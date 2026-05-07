
output "stuffed_toy_api_build_aws_sns_topic_arn" {
  value = aws_sns_topic.stuffed_toy_api_build.arn
}

output "stuffed_toy_relay_build_aws_sns_topic_arn" {
  value = aws_sns_topic.stuffed_toy_relay_build.arn
}

output "stuffed_toy_frontend_build_aws_sns_topic_arn" {
  value = aws_sns_topic.stuffed_toy_frontend_build.arn
}
