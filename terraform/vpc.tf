
# Fetch AZs in the current region
# Use with "count" meta argument
data "aws_availability_zones" "available" {
}

resource "aws_vpc" "webapp_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    Name = "WebApp-VPC"
  }
}

resource "aws_subnet" "webapp_subnet_1" {
  vpc_id                  = aws_vpc.webapp_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.webapp_vpc.cidr_block, 8, 1)
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "WebApp-Subnet-1"
  }
}

resource "aws_subnet" "webapp_subnet_2" {
  vpc_id                  = aws_vpc.webapp_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.webapp_vpc.cidr_block, 8, 2)
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "WebApp-Subnet-2"
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.webapp_vpc.id
  tags = {
    Name = "WebApp-Internet-Gateway"
  }
}

resource "aws_route_table" "internet_access" {
  vpc_id = aws_vpc.webapp_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
  tags = {
    Name = "WebApp-Default-Route"
  }
}

resource "aws_route_table_association" "subnet_route" {
  subnet_id      = aws_subnet.webapp_subnet_1.id
  route_table_id = aws_route_table.internet_access.id
}

resource "aws_route_table_association" "subnet2_route" {
  subnet_id      = aws_subnet.webapp_subnet_2.id
  route_table_id = aws_route_table.internet_access.id
}

resource "aws_security_group" "security_group" {
  name   = "ECS-Security-Group"
  vpc_id = aws_vpc.webapp_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    self        = "false"
    cidr_blocks = ["0.0.0.0/0"]
    description = "any"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

