# ----------------------------------------------------------------
# pipeline.tf
# ----------------------------------------------------------------
resource "aws_codepipeline" "terraform_pipeline" {
  name     = "my-terraform-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    type     = "S3"
    location = aws_s3_bucket.codepipeline_artifacts.bucket
  }

  stage {
    name = "Source"

    action {
      name             = "GitHub_Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source_output"]

      # Reference your GitHub repo details
      configuration = {
        Owner      = "marceloflcruz"
        Repo       = "fiap-infra-ecs-cicd"
        Branch     = "main"
        # OAuthToken = var.github_token  # sensitive variable
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Terraform_Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      configuration = {
        ProjectName = aws_codebuild_project.terraform_build_project.name
      }
    }
  }

  # Optional: Additional stages like Deploy, Approvals, etc.
}