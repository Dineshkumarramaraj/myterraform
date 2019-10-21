aws_region   = "us-west-1"
project_name = "dinesh-terraform"
vpc_cidr     = "10.123.0.0/16"
public_cidrs = [
  "10.123.1.0/24",
  "10.123.2.0/24"
]
accessip    = "0.0.0.0/0"
key_name = "testkey"
public_key_path = "~/.ssh/testkey.pub"
server_instance_type = "t2.micro"
instance_count = 2
