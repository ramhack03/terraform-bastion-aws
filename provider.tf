terraform {
  backend "s3" {
    bucket       = "terraform-bastion-state-339713120550"
    key          = "terraform-bastion/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
