#creating security group with inbound and outbound rules
resource "aws_security_group" "Allow-all" {
  vpc_id      = aws_vpc.Terra-Vpc.id
  name        = "Allow-all"
  description = "Allow all inbound and outbound traffic"

  tags = {
    Name = "Allow-all"
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
