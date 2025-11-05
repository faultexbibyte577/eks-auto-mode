provider "aws" {
  region = var.aws_region
}

module "eks-automode" {
  source = "./modules/eks"

  cluster_name       = var.cluster_name
  cluster_version    = var.cluster_version
  vpc_id             = module.network.vpc_id
  private_subnet_ids = module.network.private_subnet_ids
  region             = var.aws_region
  environment        = var.environment

}

module "network" {
  source = "./modules/network"

  cluster_name  = var.cluster_name
  environment   = var.environment
  vpc_cidr      = var.vpc_cidr
  default-route = var.default-route
  project_name  = var.project_name
}