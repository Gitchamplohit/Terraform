data "aws_vpc" "Terra-Vpc" {
  id = "vpc-040948483337a44e4"

}

data "aws_subnet" "PUB-Terra-Sub" {
  id = "subnet-0dda712d1c025b02b"
}

data "aws_security_group" "Allow-all" {
  id = "sg-0e5947d4b9e6ad318"
}
