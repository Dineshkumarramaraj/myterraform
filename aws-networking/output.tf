output "vpc_details" {
  value = module.networking.vpc_details
}

output "zones" {
    value = module.networking.zones
}

output "subnets" {
    value = module.networking.subnets
}