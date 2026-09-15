resource "aws_s3_bucket" "bad" {
  bucket = "demo-public-bucket"
  acl    = "public-read"
}

resource "aws_s3_bucket_public_access_block" "bad" {
  bucket = aws_s3_bucket.bad.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}
