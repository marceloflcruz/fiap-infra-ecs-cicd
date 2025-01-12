# ----------------------------------------------------------------
# codebuild.tf
# ----------------------------------------------------------------
resource "aws_codebuild_project" "terraform_build_project" {
  name         = "terraform-build-project"
  service_role = "arn:aws:iam::185983175555:role/CodeBuildServiceRole"
  # service_role = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = true  # If needed for Docker-in-Docker

    environment_variable {
      name  = "GITHUB_TOKEN"
      type  = "SECRETS_MANAGER"
      value = "/fiap/terraform/github_token"  # The name of your secret
    }
  }

  # The source for CodeBuild is "CODEPIPELINE" 
  # (the pipeline will hand off the artifact to CodeBuild)
  source {
    type      = "CODEPIPELINE"
    buildspec = file("buildspec.yml")
  }

  # Optionally store logs in CloudWatch
  logs_config {
    cloudwatch_logs {
      group_name  = "/aws/codebuild/terraform-build-project"
      stream_name = "build-log"
    }
  }
}
