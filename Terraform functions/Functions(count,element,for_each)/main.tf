provider "aws" {
  region = var.region_name

}

# storing statefile in S3 as backend
terraform {
  backend "s3" {
    bucket = "terraformfunctionsetesting"
    key    = "functions.tfstate"
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

# creating multiple public subnets with the help of count  and element function
resource "aws_subnet" "PUB-subnet" {
  #count                   = 3
  count                   = length(var.pub-sub-cidr)
  vpc_id                  = aws_vpc.Terra-Vpc.id
  cidr_block              = element(var.pub-sub-cidr, count.index)
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = "true"

  tags = {
    Name       = "${var.pub-sub-tag}-${count.index + 1}"
    Owner      = local.Owner      #using locals function for tagging the subnets     
    costcenter = local.costcenter #using locals function for tagging the subnets
    teamDL     = local.teamDL     #using locals function for tagging the subnets
  }

}

# associating pub subnet to pub RT
resource "aws_route_table_association" "PUB-Sub" {
  #count          = 3
  count          = length(var.pub-sub-cidr)
  route_table_id = aws_route_table.Terra-PUB-RT.id
  subnet_id      = element(aws_subnet.PUB-subnet.*.id, count.index)

}

# creating Pvt RT
resource "aws_route_table" "Terra-Pvt-RT" {
  vpc_id = aws_vpc.Terra-Vpc.id

  tags = {
    Name = var.Pvt-RT-tag
  }

}

# creating multiple pvt subnets with the help of count  and element function
resource "aws_subnet" "Pvt-subnet" {
  #  count             = 3
  count             = length(var.pvt-sub-cidr)
  vpc_id            = aws_vpc.Terra-Vpc.id
  cidr_block        = element(var.pvt-sub-cidr, count.index)
  availability_zone = element(var.azs, count.index)

  tags = {
    Name       = "${var.pvt-sub-tag}-${count.index + 1}"
    Owner      = local.Owner      #using locals function for tagging the subnets
    costcenter = local.costcenter #using locals function for tagging the subnets
    teamDL     = local.teamDL     #using locals function for tagging the subnets
  }
}

# associating pvt subnet to pvt RT
resource "aws_route_table_association" "Pvt-sub" {
  # count          = 3
  count          = length(var.pvt-sub-cidr)
  route_table_id = aws_route_table.Terra-Pvt-RT.id
  subnet_id      = element(aws_subnet.Pvt-subnet.*.id, count.index)

}



#resource "aws_instance" "web-1" {
#  ami                         = "ami-09b0a86a2c84101e1"
#  instance_type               = "t2.micro"
#  availability_zone           = "ap-south-1a"
#  key_name                    = "key"
#  subnet_id                   = aws_subnet.PUB-subnet
#  vpc_security_group_ids      = [aws_security_group.Allow-all.id]
#  associate_public_ip_address = "true"
#
#  tags = {
#    Name       = "web-1"
#    Env        = var.env
#    Owner      = local.Owner      #using locals function for tagging the subnets
#    costcenter = local.costcenter #using locals function for tagging the subnets
#    teamDL     = local.teamDL     #using locals function for tagging the subnets
#  }
#  user_data = <<-EOF
#    #!/bin/bash
#    sudo apt-get update
#    sudo apt install nginx -y
#    echo "<h1> ${var.env}-server-1 </h1>" | sudo tee /var/www/html/index.html
#    sudo systemctl start nginx
#    sudo systemctl enable nginx
#  EOF
#
#
#}
