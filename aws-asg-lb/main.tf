
# Using AWS as a Provider
provider aws {
    region = "us-east-1"
}

#Port 8080 doesnt require root access so using for experiment. 
variable "port" {
    type = number
    default = 8080
}

# In Terraform data resource is for read only data from existing environment.
# In AWS, by default VPC and subnets are created. 
# In order to access those we are using data resource. 
data "aws_vpc" "default" {
    default = true
}

data "aws_subnet_ids" "default"{
   vpc_id = data.aws_vpc.default.id
}

# Autoscaling Configuration

resource "aws_launch_configuration" "myterraformlauchconfig" {
    image_id = "ami-04b9e92b5572fa0d1"
    instance_type = "t2.micro"
    security_groups = [aws_security_group.myterraformsecurity.id]

    user_data = <<-EOT
                 #!/bin/bash
                 echo "Hello World" > index.html
                 nohup busybox httpd -f -p ${var.port} &
                 EOT

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_autoscaling_group" "myterraformasg" {
    launch_configuration = aws_launch_configuration.myterraformlauchconfig.name
    vpc_zone_identifier = data.aws_subnet_ids.default.ids

    target_group_arns = [aws_lb_target_group.myterraformtargetgroup.arn]
    health_check_type = "ELB"

    min_size = 2
    max_size = 10

    tag {
        key = "Name"
        value = "MyterraformASG"
        propagate_at_launch = true
    }
}
#End of Auto scaling configuration

# Security group for opening port 80(http) and 8080
resource "aws_security_group" "myterraformsecurity" {
    name = "terraform_security"
    ingress  {
        from_port = var.port
        to_port = var.port
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "myterraformalbsecurity" {
    name = "terraform-lb-security"

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

# Load Balancer
resource "aws_lb" "myterraformalb" {
    name = "terraformalb"
    load_balancer_type = "application"
    subnets = data.aws_subnet_ids.default.ids
    security_groups = [aws_security_group.myterraformalbsecurity.id]
}

resource "aws_lb_listener" "myterraformlistener" {
    load_balancer_arn = aws_lb.myterraformalb.arn
    port = 80
    protocol = "HTTP"

    default_action {
        type = "fixed-response"

        fixed_response {
            content_type = "text/plain"
            message_body = "404: page not found"
            status_code = 404
        }
    }
}

resource "aws_lb_target_group" "myterraformtargetgroup" {
    name = "myterraform-lb-target-group"
    port = var.port
    protocol = "HTTP"
    vpc_id = data.aws_vpc.default.id

    health_check {
        path = "/"
        protocol = "HTTP"
        matcher = "200"
        interval = 15
        timeout = 3
        healthy_threshold = 2
        unhealthy_threshold = 2
    }
}

resource "aws_lb_listener_rule" "myterraformlistenerrule" {
    listener_arn = aws_lb_listener.myterraformlistener.arn
    priority = 100

    condition {
        field = "path-pattern"
        values = ["*"]
    }

    action {
        type = "forward"
        target_group_arn = aws_lb_target_group.myterraformtargetgroup.arn
    }
}

#End of Load Balancer. 

output "alb_dns_name" {
    value = aws_lb.myterraformalb.dns_name
}
  
