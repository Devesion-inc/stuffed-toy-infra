
resource "aws_iam_role" "stuffed_toy_api_ecs_task" {
  name = "stuffed-toy-api-ecs-task-role-${var.env_value_environment}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "stuffed_toy_api_ecs_task" {
  role       = aws_iam_role.stuffed_toy_api_ecs_task.name
  policy_arn = var.stuffed_toy_api_ecs_task_aws_iam_policy_arn
}
