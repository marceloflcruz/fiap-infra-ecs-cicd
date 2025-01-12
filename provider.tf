# ----------------------------------------------------------------
# provider.tf
# ----------------------------------------------------------------
provider "aws" {
  region = "us-east-1"
}

# We need to pass in a GitHub OAuth token securely, e.g. from Terraform variables
# variable "github_token" {
#   type      = string
#   sensitive = true
# }

# Example usage:
# terraform apply -var="github_token=<YOUR_GITHUB_PERSONAL_ACCESS_TOKEN>"
