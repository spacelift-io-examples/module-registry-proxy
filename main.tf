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
}

output "api_endpoint" {
  value = module.tfe-module-proxy.api_endpoint
}
