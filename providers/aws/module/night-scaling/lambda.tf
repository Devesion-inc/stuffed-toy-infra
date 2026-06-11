# =============================================================================
# Start Lambda
# =============================================================================

data "archive_file" "stuffed_toy_night_scaling_start" {
  type        = "zip"
  source_file = "${path.module}/src/start.mjs"
  output_path = "${path.module}/dist/start.zip"
}

resource "aws_lambda_function" "stuffed_toy_night_scaling_start" {
  function_name = "stuffed-toy-night-scaling-start-${var.env_value_environment}"
  role          = aws_iam_role.stuffed_toy_night_scaling_lambda.arn
  handler       = "start.handler"
  runtime       = "nodejs22.x"
  timeout       = 60
  memory_size   = 128

  filename         = data.archive_file.stuffed_toy_night_scaling_start.output_path
  source_code_hash = filebase64sha256("${path.module}/src/start.mjs")

  environment {
    variables = {
      EC2_INSTANCE_IDS = jsonencode(var.ec2_instance_ids)
    }
  }
}

# =============================================================================
# Stop Lambda
# =============================================================================

data "archive_file" "stuffed_toy_night_scaling_stop" {
  type        = "zip"
  source_file = "${path.module}/src/stop.mjs"
  output_path = "${path.module}/dist/stop.zip"
}

resource "aws_lambda_function" "stuffed_toy_night_scaling_stop" {
  function_name = "stuffed-toy-night-scaling-stop-${var.env_value_environment}"
  role          = aws_iam_role.stuffed_toy_night_scaling_lambda.arn
  handler       = "stop.handler"
  runtime       = "nodejs22.x"
  timeout       = 60
  memory_size   = 128

  filename         = data.archive_file.stuffed_toy_night_scaling_stop.output_path
  source_code_hash = filebase64sha256("${path.module}/src/stop.mjs")

  environment {
    variables = {
      EC2_INSTANCE_IDS = jsonencode(var.ec2_instance_ids)
    }
  }
}

# =============================================================================
# EventBridge スケジュール（任意。scheduling_enabled = true で有効化）
# =============================================================================

resource "aws_cloudwatch_event_rule" "stuffed_toy_night_scaling_start" {
  name                = "stuffed-toy-night-scaling-start-${var.env_value_environment}"
  description         = "Auto-start EC2 instances"
  schedule_expression = var.start_schedule
  state               = var.scheduling_enabled ? "ENABLED" : "DISABLED"
}

resource "aws_cloudwatch_event_target" "stuffed_toy_night_scaling_start" {
  rule      = aws_cloudwatch_event_rule.stuffed_toy_night_scaling_start.name
  target_id = "stuffed-toy-night-scaling-start"
  arn       = aws_lambda_function.stuffed_toy_night_scaling_start.arn
}

resource "aws_lambda_permission" "stuffed_toy_night_scaling_start" {
  statement_id  = "AllowExecutionFromEventBridgeStart"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.stuffed_toy_night_scaling_start.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.stuffed_toy_night_scaling_start.arn
}

resource "aws_cloudwatch_event_rule" "stuffed_toy_night_scaling_stop" {
  name                = "stuffed-toy-night-scaling-stop-${var.env_value_environment}"
  description         = "Auto-stop EC2 instances"
  schedule_expression = var.stop_schedule
  state               = var.scheduling_enabled ? "ENABLED" : "DISABLED"
}

resource "aws_cloudwatch_event_target" "stuffed_toy_night_scaling_stop" {
  rule      = aws_cloudwatch_event_rule.stuffed_toy_night_scaling_stop.name
  target_id = "stuffed-toy-night-scaling-stop"
  arn       = aws_lambda_function.stuffed_toy_night_scaling_stop.arn
}

resource "aws_lambda_permission" "stuffed_toy_night_scaling_stop" {
  statement_id  = "AllowExecutionFromEventBridgeStop"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.stuffed_toy_night_scaling_stop.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.stuffed_toy_night_scaling_stop.arn
}
