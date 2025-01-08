resource "aws_instance" "web-1" {
  ami                         = "ami-09b0a86a2c84101e1"
  instance_type               = "t2.micro"
  availability_zone           = "ap-south-1a"
  key_name                    = "ke"
  subnet_id                   = data.aws_subnet.PUB-Terra-Sub.id
  vpc_security_group_ids      = [data.aws_security_group.Allow-all.id]
  associate_public_ip_address = "true"

  tags = {
    Name = "web-1"
    Env  = "dev"
  }

  # lifecycle {
  #   prevent_destroy = true
  # }
}

terraform {
  backend "s3" {
    bucket = "terraformstatefiletesting"
    key    = "ec2.tfstate"
    region = "ap-south-1"
  }
}
