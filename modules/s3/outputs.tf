output "s3_bucket_arn" {
  value = aws_s3_bucket.this.arn
}

output "s3_bucket_id" {
  value = aws_s3_bucket.this.id
}

output "s3_bucket_domain" {
  value = aws_s3_bucket.this.bucket_domain_name
}