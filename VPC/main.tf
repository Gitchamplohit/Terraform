provider "aws" {
  region = var.region_name

}

# storing statefile in S3 as backend
terraform {
  backend "s3" {
    bucket = "terraformstatefiletesting"
    key    = "Base-infa.tfstate"
    region = "ap-south-1"

  }
}

## Creating a VPC
resource "aws_vpc" "Terra-Vpc" {
  cidr_block           = var.vpc-cidr
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc-tag
  }
}

# creating an IGW and attaching to VPC
resource "aws_internet_gateway" "Terra-IGW" {
  vpc_id = aws_vpc.Terra-Vpc.id
  tags = {
    Name = var.IGW-tag
  }

}

# creating a pub RT and associating IGW to it
resource "aws_route_table" "Terra-PUB-RT" {
  vpc_id = aws_vpc.Terra-Vpc.id

  route {
    cidr_block = var.RT-cidr
    gateway_id = aws_internet_gateway.Terra-IGW.id
  }

  tags = {
    Name = var.RT-tag
  }

}

# creating pub subnet
resource "aws_subnet" "PUB-Terra-Sub" {
  vpc_id                  = aws_vpc.Terra-Vpc.id
  cidr_block              = var.sub-cidr
  availability_zone       = var.pub-sub-az
  map_public_ip_on_launch = "true"

  tags = {
    Name = var.pub-sub-tag
  }

}

# associating pub subnet to pub RT
resource "aws_route_table_association" "PUB-Sub" {
  route_table_id = aws_route_table.Terra-PUB-RT.id
  subnet_id      = aws_subnet.PUB-Terra-Sub.id

}

# creating Pvt RT
resource "aws_route_table" "Terra-Pvt-RT" {
  vpc_id = aws_vpc.Terra-Vpc.id

  tags = {
    Name = var.Pvt-RT-tag
  }

}

# creating a pvt subnet 
resource "aws_subnet" "Pvt-terra-sub" {
  vpc_id            = aws_vpc.Terra-Vpc.id
  cidr_block        = var.pvt-sub-cidr
  availability_zone = var.az

  tags = {
    Name = var.pvt-sub-tag
  }
}

# associating pvt subnet to pvt RT
resource "aws_route_table_association" "Pvt-sub" {
  route_table_id = aws_route_table.Terra-Pvt-RT.id
  subnet_id      = aws_subnet.Pvt-terra-sub.id

}

#creating security group with inbound and outbound rules
resource "aws_security_group" "Allow-all" {
  vpc_id      = aws_vpc.Terra-Vpc.id
  name        = "Allow-all"
  description = "Allow all inbound and outbound traffic"

  tags = {
    Name = "Allow-all"
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
