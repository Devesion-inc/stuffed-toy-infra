# EC2 instance profile

resource "aws_iam_role" "stuffed_toy_tts_ec2" {
  name = "stuffed-toy-tts-ec2-role-${var.env_value_environment}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# カスタムポリシー: ログ / メトリクス / SSM Parameter Store
resource "aws_iam_policy" "stuffed_toy_tts_ec2_custom" {
  name = "stuffed-toy-tts-ec2-policy-${var.env_value_environment}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:PutLogEvents",
          "logs:CreateLogStream",
          "logs:CreateLogGroup",
          "logs:PutRetentionPolicy",
          "cloudwatch:PutMetricData"
        ]
        Resource = ["*"]
      },
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameters",
          "ssm:GetParameter",
          "ssm:GetParametersByPath"
        ]
        Resource = ["*"]
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeTags"
        ]
        Resource = ["*"]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "stuffed_toy_tts_ec2_custom" {
  role       = aws_iam_role.stuffed_toy_tts_ec2.name
  policy_arn = aws_iam_policy.stuffed_toy_tts_ec2_custom.arn
}

# AWS マネージドポリシー（foodex パターン踏襲）

# SSM Session Manager（SSH なしでログイン）
resource "aws_iam_role_policy_attachment" "stuffed_toy_tts_ec2_ssm" {
  role       = aws_iam_role.stuffed_toy_tts_ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# CloudWatch Agent でメトリクス送信
resource "aws_iam_role_policy_attachment" "stuffed_toy_tts_ec2_cloudwatch" {
  role       = aws_iam_role.stuffed_toy_tts_ec2.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# ECR から image pull
resource "aws_iam_role_policy_attachment" "stuffed_toy_tts_ec2_ecr" {
  role       = aws_iam_role.stuffed_toy_tts_ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_instance_profile" "stuffed_toy_tts_ec2" {
  name = "stuffed-toy-tts-ec2-instance-profile-${var.env_value_environment}"
  role = aws_iam_role.stuffed_toy_tts_ec2.name
}
