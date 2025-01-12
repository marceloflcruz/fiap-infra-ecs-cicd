# ----------------------------------------------------------------
# s3.tf
# ----------------------------------------------------------------
resource "aws_s3_bucket" "codepipeline_artifacts" {
  bucket = "my-terraform-codepipeline-artifacts-${random_string.unique.result}"  # Must be globally unique
  acl    = "private"
}

resource "random_string" "unique" {
  length  = 6
  special = false
}