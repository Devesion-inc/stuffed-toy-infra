
resource "aws_iam_role" "stuffed_toy_night_scaling_lambda" {
  name = "stuffed-toy-night-scaling-lambda-role-${var.env_value_environment}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "stuffed_toy_night_scaling_lambda_basic" {
  role       = aws_iam_role.stuffed_toy_night_scaling_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "stuffed_toy_night_scaling_ec2" {
  name = "stuffed-toy-night-scaling-ec2-policy-${var.env_value_environment}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:StartInstances",
          "ec2:StopInstances",
          "ec2:DescribeInstances"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "stuffed_toy_night_scaling_ec2" {
  role       = aws_iam_role.stuffed_toy_night_scaling_lambda.name
  policy_arn = aws_iam_policy.stuffed_toy_night_scaling_ec2.arn
}
