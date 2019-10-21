# This is networking/main.tf

data "aws_availability_zones" "azs" {}

resource "aws_vpc" "tf_vpc" {
    cidr_block = var.vpc_cidr
    enable_dns_hostnames = true
    enable_dns_support = true
    tags = {
        Name = "tf_vpc"
    }
}

resource "aws_internet_gateway" "tf_internet_gateway" {
    vpc_id = aws_vpc.tf_vpc.id
    tags = {
        Name = "tf_igw"
    }
}

resource "aws_route_table" "tf_public_rt" {
    vpc_id = aws_vpc.tf_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.tf_internet_gateway.id
    }

    tags = {
        Name = "tf_public"
    }
}

resource "aws_default_route_table" "tf_private_rt" {
    default_route_table_id = aws_vpc.tf_vpc.default_route_table_id
    tags = {
        Name = "tf_private"
    }
}

resource "aws_subnet" "tf_public_subnet" {
    count = length(data.aws_availability_zones.azs.names)
    availability_zone = element(data.aws_availability_zones.azs.names, count.index)
    vpc_id = aws_vpc.tf_vpc.id
    cidr_block = element(var.public_cidrs, count.index)
    tags = {
        Name = format("tf_public_%d", count.index+1)
    }
}

# resource "aws_route_table_association" "tf_public_assoc" {
#     count          = length(aws_subnet.tf_public_subnet)
#     subnet_id      = "aws_subnet.tf_public_subnet.*.id[count.index]"
#     route_table_id = "aws_route_table.tf_public_rt.id"
# }

resource "aws_security_group" "tf_public_sg" {
    name = "tf_public_sg"
    vpc_id = aws_vpc.tf_vpc.id

    dynamic "ingress" {
        for_each = [ for s in var.service_ports: {
            from_port = s.from_port
            to_port = s.to_port
        }]

        content {
            from_port = ingress.value.from_port
            to_port = ingress.value.to_port
            protocol = "tcp"
            cidr_blocks = [var.accessip]

        }
    }
}
