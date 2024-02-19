terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.37.0"
    }

    archive = {
      source  = "hashicorp/archive"
      version = "2.4.2"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

module "tfe-module-proxy" {
  source = "./tfe-module-proxy"

  artifacts_path = "${path.root}/artifacts"

  # Update these two parameters to point at your correct Spacelift URL and account name
  spacelift_base_url     = "https://spacelift.someorg.com"
  spacelift_account_name = "admin"
}

output "api_endpoint" {
  value = module.tfe-module-proxy.api_endpoint
}
