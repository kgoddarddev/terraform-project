terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}
provider "aws" {
  shared_credentials_files = ["~/.aws/credentials"]
  profile    = ["ilab"]
}              
#provider "aws" {
#  region     = "us-west-2"
#  profile    = "default"
#}

