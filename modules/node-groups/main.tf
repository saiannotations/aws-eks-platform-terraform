# ---------------------------------------------------------------------------
# Managed node groups: AWS runs the nodes, we declare the desired shape.
# Mix on-demand (stable baseline) with spot (cheap burst capacity).
# ---------------------------------------------------------------------------

locals {
  common_tags = merge(var.tags, {
    Project     = var.project
    Environment = var.environment
  })
}

resource "aws_iam_role" "nodes" {
  name = "${var.cluster_name}-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = local.common_tags
}

locals {
  node_policies = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
  ])
}

resource "aws_iam_role_policy_attachment" "nodes" {
  for_each   = local.node_policies
  role       = aws_iam_role.nodes.name
  policy_arn = each.value
}

resource "aws_eks_node_group" "this" {
  for_each = var.node_groups

  cluster_name    = var.cluster_name
  node_group_name = "${var.cluster_name}-${each.key}"
  node_role_arn   = aws_iam_role.nodes.arn
  subnet_ids      = var.private_subnet_ids

  instance_types = each.value.instance_types
  capacity_type  = each.value.capacity_type
  disk_size      = each.value.disk_size

  scaling_config {
    min_size     = each.value.min_size
    max_size     = each.value.max_size
    desired_size = each.value.desired_size
  }

  update_config {
    max_unavailable = 1
  }

  labels = each.value.labels

  dynamic "taint" {
    for_each = each.value.taints
    content {
      key    = taint.value.key
      value  = taint.value.value
      effect = taint.value.effect
    }
  }

  tags = merge(local.common_tags, {
    Name = "${var.cluster_name}-${each.key}"
  })

  depends_on = [aws_iam_role_policy_attachment.nodes]
}
