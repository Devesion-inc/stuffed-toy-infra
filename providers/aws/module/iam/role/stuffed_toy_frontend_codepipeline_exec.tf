
resource "aws_iam_role" "stuffed_toy_frontend_codepipeline_exec" {
  name = "stuffed-toy-frontend-codepipeline-exec-role-${var.env_value_environment}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "stuffed_toy_frontend_codepipeline_exec" {
  role       = aws_iam_role.stuffed_toy_frontend_codepipeline_exec.name
  policy_arn = var.stuffed_toy_frontend_codepipeline_exec_aws_iam_policy_arn
}
