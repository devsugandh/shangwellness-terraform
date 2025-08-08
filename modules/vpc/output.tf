output "vpc_id" {
  description = "ID of the VPC"
  value = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value = module.vpc.vpc_cidr_block
}

output "public_subnets" {
  description = "IDs of the public subnets"
  value = module.vpc.public_subnets
}

output "public_subnet_ids" {
  description = "IDs of the public subnets (alias)"
  value = module.vpc.public_subnets
}

output "private_subnets" {
  description = "IDs of the private subnets"
  value = module.vpc.private_subnets
}

output "private_subnet_ids" {
  description = "IDs of the private subnets (alias)"
  value = module.vpc.private_subnets
}

output "database_subnets" {
  description = "IDs of the database subnets"
  value = module.vpc.database_subnets
}

output "database_subnet_group_name" {
  description = "Name of the database subnet group"
  value = var.database_subnet_group_name
}

output "database_subnet_group" {
  description = "Name of the database subnet group (alias)"
  value = var.database_subnet_group_name
}
