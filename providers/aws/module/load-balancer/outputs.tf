
output "stuffed_toy_api_load_balancer_arn" {
  value = aws_lb.stuffed_toy_api.arn
}

output "stuffed_toy_api_load_balancer_dns_name" {
  value = aws_lb.stuffed_toy_api.dns_name
}

output "stuffed_toy_api_load_balancer_name" {
  value = aws_lb.stuffed_toy_api.name
}

output "stuffed_toy_api_load_balancer_arn_suffix" {
  value = aws_lb.stuffed_toy_api.arn_suffix
}

output "stuffed_toy_api_main_aws_lb_listener_arn" {
  value = aws_lb_listener.stuffed_toy_api_main.arn
}

output "stuffed_toy_api_sub_aws_lb_listener_arn" {
  value = aws_lb_listener.stuffed_toy_api_sub.arn
}

output "stuffed_toy_api_main_aws_lb_listener_rule_arn" {
  value = aws_lb_listener_rule.stuffed_toy_api_main.arn
}

output "stuffed_toy_api_sub_aws_lb_listener_rule_arn" {
  value = aws_lb_listener_rule.stuffed_toy_api_sub.arn
}
