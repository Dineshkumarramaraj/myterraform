output "vpc_details" {
  value = element(split(":", aws_vpc.tf_vpc.arn), 5)
}

output "zones" {
    value = data.aws_availability_zones.default.names
}

output "subnets" {
    value = "${aws_subnet.tf_subnets_one[*].id}"
}