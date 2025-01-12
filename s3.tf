# ----------------------------------------------------------------
# s3.tf
# ----------------------------------------------------------------
# Generates a 6-character lowercase random string
resource "random_string" "bucket_suffix" {
  length  = 6
  special = false
  upper   = false
  number  = true
}

resource "aws_s3_bucket" "codepipeline_artifacts" {
  bucket = "my-terraform-codepipeline-artifacts-${random_string.bucket_suffix.result}"  # Must be globally unique
  acl    = "private"
}
