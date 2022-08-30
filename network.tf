resource "aws_subnet" "ilab_subnet_pub_a" {
  vpc_id                  = aws_vpc.imaginelabtf.id
  cidr_block              = "10.0.200.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2a"

  tags = {
    name = "ilab_public_a"
  }
}
resource "aws_subnet" "ilab_subnet_pub_b" {
  vpc_id                  = aws_vpc.imaginelabtf.id
  cidr_block              = "10.0.222.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2b"

  tags = {
    name = "ilab_public_b"
  }
}
resource "aws_subnet" "ilab_subnet_priv_a" {
  vpc_id                  = aws_vpc.imaginelabtf.id
  cidr_block              = "10.0.220.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "us-west-2a"

  tags = {
    name = "ilab_private"
  }
}


resource "aws_subnet" "ilab_subnet_private_b" {
  vpc_id                  = aws_vpc.imaginelabtf.id
  cidr_block              = "10.0.224.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "us-west-2b"

  tags = {
    name = "ilab_private_b"
  }
}

resource "aws_internet_gateway" "ilab_igw" {
  vpc_id = aws_vpc.imaginelabtf.id

  tags = {
    Name = "ilab_igw"
  }
}
#Public Route Tables
resource "aws_route_table" "ilab_pub_route_table_a" {
  vpc_id = aws_vpc.imaginelabtf.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ilab_igw.id
  }
  tags = {

    Name = "ilab public subnet route table a"
  }
}
resource "aws_route_table" "ilab_pub_route_table_b" {
  vpc_id = aws_vpc.imaginelabtf.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ilab_igw.id
  }
  tags = {

    Name = "ilab public subnet route table b"
  }
}
resource "aws_route_table_association" "imaginelab_rt_assoc_a" {
  subnet_id      = aws_subnet.ilab_subnet_pub_a.id
  route_table_id = aws_route_table.ilab_pub_route_table_a.id
}
resource "aws_route_table_association" "imaginelab_rt_assoc_b" {
  subnet_id      = aws_subnet.ilab_subnet_pub_b.id
  route_table_id = aws_route_table.ilab_pub_route_table_b.id
}

#Elastic IP for NGW
resource "aws_eip" "ilab_eip_natgw1" {
  count = "1"
}

# Create NAT gateway1
resource "aws_nat_gateway" "ilab_ngw_a" {
  count         = "1"
  allocation_id = aws_eip.ilab_eip_natgw1[count.index].id
  subnet_id     = aws_subnet.ilab_subnet_pub_a.id
}

# Create EIP for NAT GW2 

resource "aws_eip" "ilab_ngw_b" {
  count = "1"
}

# Create NAT gateway2 

resource "aws_nat_gateway" "ilab_ngw_b" {
  count         = "1"
  allocation_id = aws_eip.ilab_ngw_b[count.index].id
  subnet_id     = aws_subnet.ilab_subnet_pub_b.id
}

#Route Table for Private subnets   
resource "aws_route_table" "ilab_prv_subneta_rt" {
  count  = "1"
  vpc_id = aws_vpc.imaginelabtf.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ilab_ngw_a[count.index].id
  }
  tags = {

    Name = "ilab private subnet a route table"
  }
}
# Create route table association betn prv a & NAT GW1
resource "aws_route_table_association" "ilab_pri_sub_to_rta" {
  count          = "1"
  route_table_id = aws_route_table.ilab_prv_subneta_rt[count.index].id
  subnet_id      = aws_subnet.ilab_subnet_priv_a.id
}
# Create private route table for prv subnet b
resource "aws_route_table" "ilab_prv_subnetb_rt" {
  count  = "1"
  vpc_id = aws_vpc.imaginelabtf.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ilab_ngw_b[count.index].id
  }
  tags = {
    Name = "ilab private subnet b route table"
  }
}
# Create route table association betn prv sub2 & NAT GW2
resource "aws_route_table_association" "ilab_pri_sub_to_rtb" {
  count          = "1"
  route_table_id = aws_route_table.ilab_prv_subnetb_rt[count.index].id
  subnet_id      = aws_subnet.ilab_subnet_private_b.id
}