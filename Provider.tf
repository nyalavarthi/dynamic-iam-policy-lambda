provider "aws" {
  region = "eu-central-1"
}

#command to run init
# terraform init -backend-config=backends/dev-env.tf
terraform {
  backend "s3" {}
}