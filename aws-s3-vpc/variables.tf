# this is root/variables.tf

variable "aws_region" {
}

# Storage variables
variable "project_name" {
}

# Network variables
variable "vpc_cidr" {
}

variable "public_cidrs" {
  type = list(string)
}

variable "accessip" {
}

variable "service_ports" {
  default = [
    {
      from_port = "22"
      to_port   = "22"
    },
    {
      from_port = "80"
      to_port   = "80"
    },
  ]
}

#-------compute variables
variable "key_name" {
}

variable "public_key_path" {
}

variable "server_instance_type" {
}

variable "instance_count" {
  default = 1
}

