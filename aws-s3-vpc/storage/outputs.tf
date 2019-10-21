#This is storage/outputs.tf
output "bucketname" {
    value = "${aws_s3_bucket.tf_code.id}"
}

output "bucketarn" {
    value = "${aws_s3_bucket.tf_code.arn}"
}