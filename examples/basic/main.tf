# Minimal end-to-end example: one VPC, one cluster, one node group.
# Copy this folder to start a new environment, then adjust the inputs.

module "tagging" {
  source      = "../../modules/tagging"
  project     = "eks-platform"
  environment = "example"
}

module "vpc" {
  source               = "../../modules/vpc"
  project              = "eks-platform"
  environment          = "example"
  cluster_name         = "eks-platform-example"
  vpc_cidr             = "10.0.0.0/16"
  azs                  = ["us-east-1a", "us-east-1b"]
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]
  single_nat_gateway   = true
  tags                 = module.tagging.tags
}

module "eks" {
  source             = "../../modules/eks"
  project            = "eks-platform"
  environment        = "example"
  cluster_name       = "eks-platform-example"
  private_subnet_ids = module.vpc.private_subnet_ids
  tags               = module.tagging.tags
}

module "node_groups" {
  source             = "../../modules/node-groups"
  project            = "eks-platform"
  environment        = "example"
  cluster_name       = module.eks.cluster_name
  private_subnet_ids = module.vpc.private_subnet_ids
  node_groups = {
    default = {
      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
      min_size       = 1
      max_size       = 2
      desired_size   = 1
    }
  }
  tags = module.tagging.tags
}
