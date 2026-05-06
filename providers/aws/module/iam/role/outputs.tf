
# api
output "stuffed_toy_api_ecs_task_aws_iam_role_arn" {
  value = aws_iam_role.stuffed_toy_api_ecs_task.arn
}
output "stuffed_toy_api_ecs_exec_aws_iam_role_arn" {
  value = aws_iam_role.stuffed_toy_api_ecs_exec.arn
}
output "stuffed_toy_api_codebuild_exec_aws_iam_role_arn" {
  value = aws_iam_role.stuffed_toy_api_codebuild_exec.arn
}
output "stuffed_toy_api_codedeploy_exec_aws_iam_role_arn" {
  value = aws_iam_role.stuffed_toy_api_codedeploy_exec.arn
}
output "stuffed_toy_api_codepipeline_exec_aws_iam_role_arn" {
  value = aws_iam_role.stuffed_toy_api_codepipeline_exec.arn
}

# relay
output "stuffed_toy_relay_ecs_task_aws_iam_role_arn" {
  value = aws_iam_role.stuffed_toy_relay_ecs_task.arn
}
output "stuffed_toy_relay_ecs_exec_aws_iam_role_arn" {
  value = aws_iam_role.stuffed_toy_relay_ecs_exec.arn
}
output "stuffed_toy_relay_codebuild_exec_aws_iam_role_arn" {
  value = aws_iam_role.stuffed_toy_relay_codebuild_exec.arn
}
output "stuffed_toy_relay_codedeploy_exec_aws_iam_role_arn" {
  value = aws_iam_role.stuffed_toy_relay_codedeploy_exec.arn
}
output "stuffed_toy_relay_codepipeline_exec_aws_iam_role_arn" {
  value = aws_iam_role.stuffed_toy_relay_codepipeline_exec.arn
}
