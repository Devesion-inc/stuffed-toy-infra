# api の CodePipeline / CodeBuild 通知先

resource "aws_sns_topic" "stuffed_toy_api_build" {
  name = "stuffed-toy-api-build-${var.env_value_environment}"
}

# CodeStar Notifications から SNS に publish できるようにする
resource "aws_sns_topic_policy" "stuffed_toy_api_build" {
  arn = aws_sns_topic.stuffed_toy_api_build.arn
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "codestar-notifications.amazonaws.com"
        }
        Action   = "SNS:Publish"
        Resource = aws_sns_topic.stuffed_toy_api_build.arn
      }
    ]
  })
}
