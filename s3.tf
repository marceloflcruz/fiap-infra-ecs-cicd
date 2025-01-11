# ----------------------------------------------------------------
# s3.tf
# ----------------------------------------------------------------
resource "aws_s3_bucket" "codepipeline_artifacts" {
  bucket = "my-terraform-codepipeline-artifacts-12345"  # Must be globally unique
  acl    = "private"
}
