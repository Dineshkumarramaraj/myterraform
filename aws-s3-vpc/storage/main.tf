#This is storage/main.tf

# Create a Random ID
resource "random_id" "bucket_id" {
    byte_length = 2
}

# Create a bucket 
resource "aws_s3_bucket" "tf_code" {
    # bucket = "${var.project_name}-${random_id.bucket_id.dec}"
    bucket = format("%s-%s", var.project_name, random_id.bucket_id.dec)
    acl = "private"
    force_destroy = true
    tags = {
        Name = "oct16-bucket"
    }
}