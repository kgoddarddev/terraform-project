terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}
provider "aws" {
  shared_credentials_files = ["/home/ec2-user/.aws/credentials"]
  profile                  = "kmgoddard"
}

