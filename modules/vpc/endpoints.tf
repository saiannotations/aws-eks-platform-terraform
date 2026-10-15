# ---------------------------------------------------------------------------
# VPC endpoints: let private subnets reach ECR, S3, and CloudWatch Logs
# without going through the NAT gateway or the public internet.
# This is what allows EKS worker nodes to pull container images while
# staying in private subnets.
# ---------------------------------------------------------------------------

# S3 gateway endpoint (free, no ENIs needed).
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = aws_route_table.private[*].id

  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-s3-endpoint"
  })
}

# Security group for interface endpoints: HTTPS from inside the VPC only.
resource "aws_security_group" "endpoints" {
  name        = "${var.project}-${var.environment}-endpoints"
  description = "Allow HTTPS to VPC interface endpoints from the VPC"
  vpc_id      = aws_vpc.this.id

  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-endpoints"
  })
}

resource "aws_vpc_security_group_ingress_rule" "endpoints_https" {
  security_group_id = aws_security_group.endpoints.id
  cidr_ipv4         = aws_vpc.this.cidr_block
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  description       = "HTTPS from VPC CIDR"
}

locals {
  interface_endpoints = toset([
    "ecr.api",
    "ecr.dkr",
    "logs", # CloudWatch Logs, used by EKS control-plane logging
  ])
}

resource "aws_vpc_endpoint" "interface" {
  for_each = local.interface_endpoints

  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.${each.value}"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.endpoints.id]
  private_dns_enabled = true

  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-${each.value}-endpoint"
  })
}

data "aws_region" "current" {}
