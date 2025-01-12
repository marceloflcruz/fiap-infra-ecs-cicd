# ----------------------------------------------------------------
# iam_codebuild.tf
# ----------------------------------------------------------------
data "aws_iam_policy_document" "codebuild_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
    actions = [
      "sts:AssumeRole",
      "logs:CreateLogStream"
      ]
  }
}

resource "aws_iam_role" "codebuild_role" {
  name               = "CodeBuildServiceRole"
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume_role.json
}

# Attach policies that allow CodeBuild to do what it needs:
# - Pull code from CodePipeline (S3)
# - Possibly interact with AWS (creating ECS, VPC, etc.) -> Need broad privileges or a more specific set
resource "aws_iam_role_policy" "codebuild_role_policy" {
  name   = "CodeBuildPolicy"
  role   = aws_iam_role.codebuild_role.id
  policy = data.aws_iam_policy_document.codebuild_inline.json
}

# data "aws_iam_policy_document" "codebuild_inline" {
#   statement {
#     effect    = "Allow"
#     actions   = [
#       "s3:*",
#       "ec2:*",
#       "ecs:*",
#       "iam:PassRole",
#       "cloudformation:*",
#       # ... add more AWS permissions as needed by your Terraform
#       # Add the CloudWatch Logs actions
#       "logs:CreateLogGroup",
#       "logs:CreateLogStream",
#       "logs:PutLogEvents",
#       "logs:DescribeLogStreams"
#     ]
#     resources = ["*"]
#   }
# }

data "aws_iam_policy_document" "codebuild_inline" {
  statement {
    effect    = "Allow"
    actions   = "*"
    resources = ["*"]
  }
}