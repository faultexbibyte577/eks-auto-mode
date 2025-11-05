output "cluster_name" {
  value = module.eks-automode.cluster_name
}

output "cluster_endpoint" {
  value = module.eks-automode.cluster_endpoint
}

output "private_subnet_ids" {
  value = module.network.private_subnet_ids
}

output "vpc_id" {
  value = module.network.vpc_id
}