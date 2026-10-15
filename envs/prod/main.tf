# ---------------------------------------------------------------------------
# prod: the real thing. HA everywhere, private API, changes via CI only.
# ---------------------------------------------------------------------------

module "tagging" {
  source      = "../../modules/tagging"
  project     = var.project
  environment = var.environment
  owner       = "platform-team"
  cost_center = "engineering-prod"
}

module "vpc" {
  source             = "../../modules/vpc"
  project            = var.project
  environment        = var.environment
  cluster_name       = var.cluster_name
  vpc_cidr           = var.vpc_cidr
  azs                = var.azs
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  single_nat_gateway = false # prod: one NAT per AZ, no single point of failure
  tags               = module.tagging.tags
}

module "eks" {
  source                 = "../../modules/eks"
  project                = var.project
  environment            = var.environment
  cluster_name           = var.cluster_name
  cluster_version        = var.cluster_version
  private_subnet_ids     = module.vpc.private_subnet_ids
  endpoint_public_access = false # prod: API only reachable inside the VPC
  tags                   = module.tagging.tags
}

module "node_groups" {
  source             = "../../modules/node-groups"
  project            = var.project
  environment        = var.environment
  cluster_name       = module.eks.cluster_name
  private_subnet_ids = module.vpc.private_subnet_ids
  node_groups        = var.node_groups
  tags               = module.tagging.tags
}

module "irsa" {
  source            = "../../modules/iam-irsa"
  project           = var.project
  environment       = var.environment
  cluster_name      = module.eks.cluster_name
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_issuer_url   = module.eks.oidc_issuer_url

  roles = {
    ebs-csi = {
      namespace       = "kube-system"
      service_account = "ebs-csi-controller-sa"
      description     = "Lets the EBS CSI driver manage EBS volumes"
      policy_arns     = ["arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"]
    }
  }

  tags = module.tagging.tags
}

module "addons" {
  source       = "../../modules/addons"
  cluster_name = module.eks.cluster_name

  addons = {
    "vpc-cni" = {
      version = "v1.18.1-eksbuild.1"
    }
    "coredns" = {
      version = "v1.11.1-eksbuild.4"
    }
    "kube-proxy" = {
      version = "v1.30.0-eksbuild.3"
    }
    "aws-ebs-csi-driver" = {
      version                  = "v1.32.0-eksbuild.1"
      service_account_role_arn = module.irsa.role_arns["ebs-csi"]
    }
  }

  tags = module.tagging.tags

  depends_on = [module.node_groups]
}
