
resource "aws_iam_role" "stuffed_toy_frontend_codebuild_exec" {
  name = "stuffed-toy-frontend-codebuild-exec-role-${var.env_value_environment}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "stuffed_toy_frontend_codebuild_exec" {
  role       = aws_iam_role.stuffed_toy_frontend_codebuild_exec.name
  policy_arn = var.stuffed_toy_frontend_codebuild_exec_aws_iam_policy_arn
}
