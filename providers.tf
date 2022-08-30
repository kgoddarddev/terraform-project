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
access_key = "${params.AWS_ACCESS_KEY_ID}"
secret_key = "${params.AWS_SECRET_ACCESS_KEY}"
region     = "us-west-2"
}
