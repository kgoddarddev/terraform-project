terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}
#provider "aws" {
#  shared_credentials_files = ["~/.aws/credentials"]
#  region     = "us-west-2"
#  profile    = "ilab"
#}
provider "aws" {
access_key = var.AWS_ACCESS_KEY_ID
secret_key = var.AWS_SECRET_ACCESS_KEY
region     = "us-west-2"
}
