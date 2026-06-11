
output "stuffed_toy_night_scaling_start_lambda_name" {
  value = aws_lambda_function.stuffed_toy_night_scaling_start.function_name
}

output "stuffed_toy_night_scaling_stop_lambda_name" {
  value = aws_lambda_function.stuffed_toy_night_scaling_stop.function_name
}

output "stuffed_toy_night_scaling_start_lambda_arn" {
  value = aws_lambda_function.stuffed_toy_night_scaling_start.arn
}

output "stuffed_toy_night_scaling_stop_lambda_arn" {
  value = aws_lambda_function.stuffed_toy_night_scaling_stop.arn
}
