
# VPC Endpoint for Secrets Manager
resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnet_ids
  security_group_ids  = [var.secretsmanager_endpoint_security_group_id]
  private_dns_enabled = true

  tags = {
    Name = "stuffed-toy-secretsmanager-endpoint-${var.env_value_environment}"
  }
}
