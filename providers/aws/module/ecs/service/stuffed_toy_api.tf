
resource "aws_ecs_service" "stuffed_toy_api" {
  name                              = "stuffed-toy-api-${var.env_value_environment}"
  cluster                           = var.stuffed_toy_api_aws_ecs_cluster_id
  task_definition                   = var.stuffed_toy_api_aws_ecs_task_definition_arn
  desired_count                     = 1
  launch_type                       = "FARGATE"
  platform_version                  = "1.4.0"
  health_check_grace_period_seconds = 120
  enable_execute_command            = true
  availability_zone_rebalancing     = "ENABLED"

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  load_balancer {
    target_group_arn = var.stuffed_toy_api_blue_aws_lb_target_group_arn
    container_name   = "stuffed-toy-api-${var.env_value_environment}"
    container_port   = 3002
  }

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = var.stuffed_toy_api_ecs_security_groups
    assign_public_ip = true
  }

  lifecycle {
    ignore_changes = [
      desired_count,
      task_definition,
      load_balancer
    ]
  }
}

resource "aws_appautoscaling_target" "stuffed_toy_api" {
  service_namespace  = "ecs"
  resource_id        = "service/${var.stuffed_toy_api_aws_ecs_cluster_name}/${aws_ecs_service.stuffed_toy_api.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = var.stuffed_toy_api_ecs_min_capacity
  max_capacity       = var.stuffed_toy_api_ecs_max_capacity
}

# CPU 平均使用率 40% を維持
resource "aws_appautoscaling_policy" "stuffed_toy_api_cpu_tracking" {
  name               = "stuffed-toy-api-cpu-tracking-${var.env_value_environment}"
  resource_id        = aws_appautoscaling_target.stuffed_toy_api.resource_id
  scalable_dimension = aws_appautoscaling_target.stuffed_toy_api.scalable_dimension
  service_namespace  = aws_appautoscaling_target.stuffed_toy_api.service_namespace
  policy_type        = "TargetTrackingScaling"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = 40
    scale_in_cooldown  = 120
    scale_out_cooldown = 30
  }

  depends_on = [aws_appautoscaling_target.stuffed_toy_api]
}
