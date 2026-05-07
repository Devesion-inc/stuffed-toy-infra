
output "stuffed_toy_api_codebuild_project_name" {
  value = aws_codebuild_project.stuffed_toy_api.name
}

output "stuffed_toy_api_migrate_codebuild_project_name" {
  value = aws_codebuild_project.stuffed_toy_api_migrate.name
}

output "stuffed_toy_relay_codebuild_project_name" {
  value = aws_codebuild_project.stuffed_toy_relay.name
}

output "stuffed_toy_frontend_codebuild_project_name" {
  value = aws_codebuild_project.stuffed_toy_frontend.name
}
