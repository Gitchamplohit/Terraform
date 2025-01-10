provider "aws" {
  region = var.region_name

}

##configure the s3 backend for statefile management
terraform {
  backend "s3" {
    bucket = "erraformwithfunctionforvpcec2"
    key    = "practice.tfstate" ## can be named with ref to env as "${var.env}.tfstate" in case of multiple envs
    region = "ap-south-1"
  }
}

## creating vpc
resource "aws_vpc" "Practice-vpc" {
  cidr_block           = var.vpc-cidr
  enable_dns_hostnames = "true"

  tags = {
    Name       = var.vpc_name
    owner      = local.owner
    teamDL     = local.teamDL
    costcentre = local.costcentre
  }

}

##creating and attaching IGW to vpc
resource "aws_internet_gateway" "practice-igw" {
  vpc_id = aws_vpc.Practice-vpc.id
  tags = {
    Name = "${var.vpc_name}-IGW"
  }

}

## creating public Rt and making IGW entry
resource "aws_route_table" "Pub-RT" {
  vpc_id = aws_vpc.Practice-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.practice-igw.id
  }
  tags = {
    Name = "${var.vpc_name}-Pub-RT"
  }

}

## creating pub subnets
resource "aws_subnet" "Pub-subnet" {
  count                   = length(var.pub-sub-cidr)
  vpc_id                  = aws_vpc.Practice-vpc.id
  cidr_block              = element(var.pub-sub-cidr, count.index) ##cidr blocks are variablized, so using element(var)
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = "true"

  tags = {
    Name       = "Pub-sub-${count.index + 1}" ##naming each subnet with 1, 2 nd 3 at the ends
    owner      = local.owner
    teamDL     = local.teamDL
    costcentre = local.costcentre
  }

}

## creating subnet associations to pub-RT
resource "aws_route_table_association" "Pub-sub-asso" {
  count          = length(var.pub-sub-cidr)
  route_table_id = aws_route_table.Pub-RT.id
  subnet_id      = element(aws_subnet.Pub-subnet[*].id, count.index + 1) ## subnet id is not variablized so ntot using element(var.)

}

## creating Pvt RT
resource "aws_route_table" "Pvt-RT" {
  vpc_id = aws_vpc.Practice-vpc.id

  tags = {
    Name = "${var.vpc_name}-Pvt-RT"
  }

}

## creating Pvt subnets
resource "aws_subnet" "Pvt-subnet" {
  count             = length(var.pvt-sub-cidr)
  vpc_id            = aws_vpc.Practice-vpc.id
  cidr_block        = element(var.pvt-sub-cidr, count.index)
  availability_zone = element(var.azs, count.index)

  tags = {
    Name       = "Pvt-sub-${count.index + 1}"
    owner      = local.owner
    teamDL     = local.teamDL
    costcentre = local.costcentre
  }

}

## creating pvt subnet associations to pvt RT
resource "aws_route_table_association" "Pvt-sub-asso" {
  count          = length(var.pvt-sub-cidr)
  route_table_id = aws_route_table.Pvt-RT.id
  subnet_id      = element(aws_subnet.Pvt-subnet[*].id, count.index + 1)

}

## creating security gps for vpc and defining dynamic ingress
resource "aws_security_group" "practice-sg" {
  vpc_id      = aws_vpc.Practice-vpc.id
  name        = "practice-sg"
  description = "sg to allow all traffic"

  tags = {
    Name = "${var.vpc_name}-sg"
  }

  dynamic "ingress" {
    for_each = var.ingress_value
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

## creating ec2 instance
resource "aws_instance" "Pub-ec2" {
  ami           = lookup(var.amis, var.region_name)
  instance_type = "t2.micro"
  # count                       = var.env == "dev" ? 1 : 3  ##conditon based function
  #count = length(var.pub-sub-cidr)
  # availability_zone      = element(var.azs, count.index)
  key_name               = var.ec2_key
  vpc_security_group_ids = [aws_security_group.practice-sg.id]
  #subnet_id              = element(aws_subnet.Pub-subnet[*].id, count.index)
  subnet_id                   = aws_subnet.Pub-subnet[0].id ## in case of creating ec2 in pub-subnet-1 so no element funtion is required
  associate_public_ip_address = "true"

  tags = {
    Name       = "pub-server01" #${count.index}
    owner      = local.owner
    teamDL     = local.teamDL
    costcentre = local.costcentre
  }
  lifecycle {
    create_before_destroy = "true"
  }
  depends_on = [aws_subnet.Pub-subnet]

}

resource "null_resource" "Userdata" {
  count = length(var.pub-sub-cidr)
  provisioner "file" {
    source      = "userdata.sh"
    destination = "/tmp/userdata.sh"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("key.pem")
      host        = element(aws_instance.Pub-ec2[*].public_ip, count.index)
    }

  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod 700 /tmp/userdata.sh",
      "sudo /tmp/userdata.sh"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("key.pem")
      host        = element(aws_instance.Pub-ec2[*].public_ip, count.index)
    }
  }

}

