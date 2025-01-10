region_name   = "ap-south-1"
vpc_name      = "Practice-Vpc"
vpc-cidr      = "172.130.0.0/16"
azs           = ["ap-south-1a", "ap-south-1b"]
pub-sub-cidr  = ["172.130.1.0/24", "172.130.2.0/24", "172.130.3.0/24"]
pvt-sub-cidr  = ["172.130.10.0/24", "172.130.20.0/24", "172.130.30.0/24"]
ingress_value = ["80", "8080", "22", "443", "25"]
env           = "dev"
amis = {
  ap-south-1 = "ami-053b12d3152c0cc71"
  us-east-1  = "ami-0e2c8caa4b6378d8c"
}
ec2_key = "key"
