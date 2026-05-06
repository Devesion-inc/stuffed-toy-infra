
resource "aws_codedeploy_app" "stuffed_toy_relay" {
  compute_platform = "ECS"
  name             = "stuffed-toy-relay-${var.env_value_environment}"
}

resource "aws_codedeploy_deployment_group" "stuffed_toy_relay" {
  deployment_group_name  = "stuffed-toy-relay-${var.env_value_environment}-deployment-group"
  app_name               = aws_codedeploy_app.stuffed_toy_relay.name
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"
  service_role_arn       = var.stuffed_toy_relay_codedeploy_exec_aws_iam_role_arn

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 1
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  ecs_service {
    cluster_name = var.stuffed_toy_relay_ecs_cluster_name
    service_name = var.stuffed_toy_relay_ecs_service_name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [var.stuffed_toy_relay_lb_listener_main_arn]
      }

      test_traffic_route {
        listener_arns = [var.stuffed_toy_relay_lb_listener_sub_arn]
      }

      target_group {
        name = var.stuffed_toy_relay_blue_target_group_name
      }

      target_group {
        name = var.stuffed_toy_relay_green_target_group_name
      }
    }
  }
}
