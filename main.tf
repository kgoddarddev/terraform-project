# Create a VPC
resource "aws_vpc" "imaginelabtf" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "devtest"
  }
}

resource "aws_key_pair" "imaginelb_auth" {
  key_name   = "imagine-key"
  public_key = file("./imaginelbkey.pub")
}

