locals {
  name        = var.cluster_name
  region      = var.region
  k8s_version = var.cluster_version

  tags = {
    Environment = local.name
    GithubOrg   = "terraform-aws-modules"
  }
}