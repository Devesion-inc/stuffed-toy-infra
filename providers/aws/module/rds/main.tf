
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 6.43.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

resource "aws_db_subnet_group" "stuffed_toy_db" {
  name       = "stuffed-toy-db-subnet-group-${var.env_value_environment}"
  subnet_ids = var.subnet_ids
}

resource "aws_rds_cluster" "stuffed_toy_db" {
  cluster_identifier                  = "stuffed-toy-cluster-${var.env_value_environment}"
  engine                              = var.stuffed_toy_rds_engine
  engine_version                      = var.stuffed_toy_rds_engine_version
  database_name                       = var.stuffed_toy_rds_name
  master_username                     = var.stuffed_toy_rds_username
  master_password                     = random_password.stuffed_toy_db.result
  port                                = 5432
  vpc_security_group_ids              = var.stuffed_toy_rds_security_group_ids
  backup_retention_period             = 7
  preferred_backup_window             = "02:00-04:00"
  preferred_maintenance_window        = "mon:05:00-mon:05:30"
  copy_tags_to_snapshot               = true
  storage_encrypted                   = true
  db_subnet_group_name                = aws_db_subnet_group.stuffed_toy_db.name
  db_cluster_parameter_group_name     = aws_rds_cluster_parameter_group.stuffed_toy.name
  availability_zones                  = var.stuffed_toy_rds_availability_zones
  iam_database_authentication_enabled = true
  deletion_protection                 = true
  skip_final_snapshot                 = false
  apply_immediately                   = true
  final_snapshot_identifier           = "stuffed-toy-${var.env_value_environment}-finalsnapshot"
  # コストを抑えるため一般的な postgresql ログのみ出力（audit は出さない）
  enabled_cloudwatch_logs_exports = ["postgresql"]

  lifecycle {
    ignore_changes = [
      availability_zones,
      snapshot_identifier,
      final_snapshot_identifier,
      engine_version,
      deletion_protection,
      cluster_members
    ]
    prevent_destroy = true
  }

  depends_on = [
    random_password.stuffed_toy_db
  ]
}

resource "aws_rds_cluster_instance" "stuffed_toy_db" {
  identifier              = "stuffed-toy-instance-${var.env_value_environment}"
  cluster_identifier      = aws_rds_cluster.stuffed_toy_db.id
  engine                  = aws_rds_cluster.stuffed_toy_db.engine
  engine_version          = aws_rds_cluster.stuffed_toy_db.engine_version
  instance_class          = var.stuffed_toy_rds_instance_class
  db_subnet_group_name    = aws_rds_cluster.stuffed_toy_db.db_subnet_group_name
  db_parameter_group_name = aws_db_parameter_group.stuffed_toy.name
  publicly_accessible     = false
  monitoring_role_arn     = aws_iam_role.stuffed_toy_db_monitoring.arn
  monitoring_interval     = 60

  lifecycle {
    ignore_changes = [
      instance_class,
      performance_insights_enabled,
      engine_version
    ]
  }
}

resource "aws_appautoscaling_target" "stuffed_toy_db" {
  service_namespace  = "rds"
  scalable_dimension = "rds:cluster:ReadReplicaCount"
  resource_id        = "cluster:${aws_rds_cluster.stuffed_toy_db.id}"
  min_capacity       = var.stuffed_toy_rds_reader_capacity_min
  max_capacity       = var.stuffed_toy_rds_reader_capacity_max
  lifecycle {
    ignore_changes = [
      min_capacity,
      max_capacity
    ]
  }
  depends_on = [
    aws_rds_cluster.stuffed_toy_db,
    aws_rds_cluster_instance.stuffed_toy_db
  ]
}

resource "aws_appautoscaling_policy" "stuffed_toy_db" {
  name               = "stuffed-toy-db-autoscaling-policy-${var.env_value_environment}"
  service_namespace  = aws_appautoscaling_target.stuffed_toy_db.service_namespace
  scalable_dimension = aws_appautoscaling_target.stuffed_toy_db.scalable_dimension
  resource_id        = aws_appautoscaling_target.stuffed_toy_db.resource_id
  policy_type        = "TargetTrackingScaling"
  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "RDSReaderAverageCPUUtilization"
    }
    target_value       = 30
    scale_in_cooldown  = 180
    scale_out_cooldown = 180
    disable_scale_in   = false
  }
  depends_on = [
    aws_rds_cluster.stuffed_toy_db,
    aws_rds_cluster_instance.stuffed_toy_db
  ]
}
