# In this module we are going to create 
# VPC, Internet Gateway, Subnets, ACL, Security Groups
# and Routes

provider "aws" {
  region = "us-east-1"
}

module "networking" {
  source        = "./networking"
  vpc_cidr     = var.vpc_cidr
  subnet_cidr  = var.subnet_cidr
}

