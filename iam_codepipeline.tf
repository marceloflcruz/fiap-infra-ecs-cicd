# # ----------------------------------------------------------------
# # iam_codepipeline.tf
# # ----------------------------------------------------------------
# data "aws_iam_policy_document" "codepipeline_assume_role" {
#   statement {
#     effect = "Allow"
#     principals {
#       type        = "Service"
#       identifiers = ["codepipeline.amazonaws.com"]
#     }
#     actions = ["sts:AssumeRole"]
#   }
# }

# resource "aws_iam_role" "codepipeline_role" {
#   name               = "CodePipelineServiceRole"
#   assume_role_policy = data.aws_iam_policy_document.codepipeline_assume_role.json
#   lifecycle {
#     prevent_destroy       = true
#     create_before_destroy = false
#   }

# }

# # Attach a managed policy or inline policy granting access to S3, CodeBuild, etc.
# resource "aws_iam_role_policy" "codepipeline_role_policy" {
#   name   = "CodePipelinePolicy"
#   role   = aws_iam_role.codepipeline_role.id
#   policy = data.aws_iam_policy_document.codepipeline_inline.json
# }

# data "aws_iam_policy_document" "codepipeline_inline" {
#   statement {
#     effect = "Allow"
#     actions = [
#       "ssm:*",
#       "s3:*",
#       "logs:*",
#       "iam:*",
#       "ecs:*",
#       "ec2:*",
#       "codebuild:*",
#       "cloudformation:*"
#     ]
#     resources = [
#       "arn:aws:iam::185983175555:role/CodeBuildServiceRole",
#       "arn:aws:s3:::*",
#       "arn:aws:codebuild:us-east-1:185983175555:*"
#     ]
#   }
# }
