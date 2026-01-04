# creating VPC
resource "aws_vpc" "node-vpc" {
  cidr_block       = "10.0.0.0/16"

  tags = {
    Name = "node-vpc"
  }
}

# creating internet gateway
resource "aws_internet_gateway" "node-gw" {
  vpc_id = aws_vpc.node-vpc.id

  tags = {
    Name = "node-gw"
  }
}

# creating public subnet
resource "aws_subnet" "public-subnet" {
  count = 2  
  vpc_id     = aws_vpc.node-vpc.id
  cidr_block = "10.0.${count.index}.0/24"
  map_public_ip_on_launch = true
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "public-subnet-${count.index}"
  }
}

# creating private subnet
resource "aws_subnet" "private-subnet" {
  count = 2  
  vpc_id     = aws_vpc.node-vpc.id
  cidr_block = "10.0.${count.index + 10}.0/24"
  map_public_ip_on_launch = true
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "private-subnet-${count.index}"
  }
}

# creating Elastic IP(eip)
resource "aws_eip" "node-eip" {
  count = 1
  domain   = "vpc"
}

#creating nat gateway
resource "aws_nat_gateway" "node-nat" {
  allocation_id = aws_eip.node-eip[0].id
  subnet_id     = aws_subnet.public-subnet[0].id

  tags = {
    Name = "node-nat"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.node-gw]
}

# creating public route table
resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.node-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.node-gw.id
  }

  tags = {
    Name = "public-rt"
  }
}

# creating private route table
resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.node-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.node-nat.id
  }

  tags = {
    Name = "private-rt"
  }
}

# creating public route table association
resource "aws_route_table_association" "public-rta" {
  count = length(aws_subnet.public-subnet)
  subnet_id      = aws_subnet.public-subnet[count.index].id
  route_table_id = aws_route_table.public-rt.id
}

# creating private route table association
resource "aws_route_table_association" "private-rta" {
  count = length(aws_subnet.private-subnet)
  subnet_id      = aws_subnet.private-subnet[count.index].id
  route_table_id = aws_route_table.private-rt.id
}

# creating ECR(Elastic container registry) repository
resource "aws_ecr_repository" "App" {
  name = "node-repo"
  image_scanning_configuration {
    scan_on_push = true
  }
  force_delete = true
}