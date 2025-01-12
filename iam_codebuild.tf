# ----------------------------------------------------------------
# iam_codebuild.tf
# ----------------------------------------------------------------

# Define the policy document for the assume role
# data "aws_iam_policy_document" "codebuild_assume_role" {
#   statement {
#     effect = "Allow"
#     principals {
#       type        = "Service"
#       identifiers = ["codebuild.amazonaws.com"] # Specific AWS service
#     }
#     actions = ["sts:AssumeRole"] # Define allowed actions
#   }
# }

# # Create the IAM Role for CodeBuild
# resource "aws_iam_role" "codebuild_role" {
#   name               = "CodeBuildServiceRole"
#   assume_role_policy = data.aws_iam_policy_document.codebuild_assume_role.json
# }

# # Attach policies that allow CodeBuild to do what it needs:
# # - Pull code from CodePipeline (S3)
# # - Possibly interact with AWS (creating ECS, VPC, etc.) -> Need broad privileges or a more specific set
# resource "aws_iam_role_policy" "codebuild_role_policy" {
#   name   = "CodeBuildPolicy"
#   role   = aws_iam_role.codebuild_role.id
#   policy = data.aws_iam_policy_document.codebuild_inline.json
#   lifecycle {
#     prevent_destroy       = true
#     create_before_destroy = false
#   }

# }

# data "aws_iam_policy_document" "codebuild_inline" {
#   statement {
#     effect = "Allow"
#     actions = [
#       "ssm:*",
#       "s3:*",
#       "logs:*",
#       "iam:*",
#       "ecs:*",
#       "ec2:*",
#       "cloudformation:*",
#       "secretsmanager:*"
#     ]
#     resources = ["*"]
#   }
# }
