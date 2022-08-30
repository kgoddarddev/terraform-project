terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}
#provider "aws" {
#  shared_credentials_files = ["/home/ec2-user/.aws/credentials"]
#  profile    = "kgoddard"
#}              
provider "aws" {
  region     = "us-west-2"
  access_key = AWS_ACCESS_KEY_ID
  secret_key = AWS_SECRET_ACCESS_KEY
}

