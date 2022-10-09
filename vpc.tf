terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
    profile = "rj"
    region = "us-west-1"
}



resource "aws_vpc" "vpc1" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "vpc1"
  }
}

resource "aws_subnet" "Public" {
  vpc_id     = aws_vpc.vpc1.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-west-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "Public"
  }
}


resource "aws_subnet" "Private" {
  vpc_id     = aws_vpc.vpc1.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-west-1b"
  tags = {
    Name = "Private"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc1.id

  tags = {
    Name = "igw"
  }
}

resource "aws_eip" "elastic" {
    vpc       = true

  tags = {
    Name = "elastic"
  }
} 

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.elastic.id
  subnet_id     = aws_subnet.Public.id

  tags = {
    Name = "gw NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route_table" "Public-rt" {
  vpc_id = aws_vpc.vpc1.id
  tags = {
    Name = "Public-rt"
  }
}

resource "aws_route_table" "Private-rt" {
  vpc_id = aws_vpc.vpc1.id
  tags = {
    Name = "Private-rt"
  }
}

resource "aws_route" "public-route" {
  route_table_id            = aws_route_table.Public-rt.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
  depends_on                = [aws_route_table.Public-rt]
}

resource "aws_route" "private-route" {
  route_table_id            = aws_route_table.Private-rt.id
  destination_cidr_block    = "10.0.2.0/24"
  nat_gateway_id = aws_nat_gateway.nat.id
  depends_on                = [aws_route_table.Private-rt]
}

resource "aws_route_table_association" "Public-asso" {
  subnet_id      = aws_subnet.Public.id
  route_table_id = aws_route_table.Public-rt.id
}

resource "aws_route_table_association" "Private-asso" {
  subnet_id      = aws_subnet.Private.id
  route_table_id = aws_route_table.Private-rt.id
}

resource "aws_security_group" "public-allow" {
  name        = "public allow"
  description = "ssh http allow"
  vpc_id      = aws_vpc.vpc1.id

  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
   ingress {
    description = "http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "public"
  }
}

resource "aws_security_group" "private-allow" {
  name        = "private ssh allow"
  description = "ssh allow"
  vpc_id      = aws_vpc.vpc1.id

  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "private"
  }
}
