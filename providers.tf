terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}
provider "aws" {
  region                  = "us-west-2"
  shared_credentials_file = "/Users/close/.aws/credentials"
  profile                 = "kgoddard"
}