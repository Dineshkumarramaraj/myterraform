# In this module we are going to create 
# VPC, Internet Gateway, Subnets, ACL, Security Groups
# and Routes

data "aws_availability_zones" "default" { }


resource "aws_vpc" "tf_vpc" {
  cidr_block = var.vpc_cidr
  tags = {
      Name = "tf_vpc"
  }
}

resource "aws_internet_gateway" "tf_igw" {
  vpc_id = aws_vpc.tf_vpc.id

  tags = {
      Name = "tf_igw"
  }
}

resource "aws_route" "tf_public_route" {
  route_table_id = aws_vpc.tf_vpc.default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.tf_igw.id
}


resource "aws_subnet" "tf_subnets_one" {
  count = length(data.aws_availability_zones.default.names)
  availability_zone = element(data.aws_availability_zones.default.names, count.index)
  vpc_id = aws_vpc.tf_vpc.id
  cidr_block = element(var.subnet_cidr, count.index)

  tags = {
      "Name" = format("tf_subnets_%d", count.index+1)
  }
}

