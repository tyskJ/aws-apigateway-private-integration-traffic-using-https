/************************************************************
VPC
************************************************************/
resource "aws_vpc" "this" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "vpc"
  }
}

/************************************************************
Subnet
************************************************************/
resource "aws_subnet" "private_a" {
  vpc_id                  = aws_vpc.this.id
  availability_zone       = "${local.region_name}a"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = false
  tags = {
    Name = "private-subnet-a"
  }
}

resource "aws_subnet" "private_c" {
  vpc_id                  = aws_vpc.this.id
  availability_zone       = "${local.region_name}c"
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = false
  tags = {
    Name = "private-subnet-c"
  }
}

/************************************************************
Security Group
************************************************************/
resource "aws_security_group" "alb_sg" {
  vpc_id      = aws_vpc.this.id
  name        = "alb-sg"
  description = "For ALB"
  tags = {
    Name = "alb-sg"
  }
}

resource "aws_security_group" "vpclinkv2_sg" {
  vpc_id      = aws_vpc.this.id
  name        = "vpc-link-sg"
  description = "For VPC LINK V2"
  tags = {
    Name = "vpc-link-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_sg_allow_http_from_vpclinksg" {
  security_group_id            = aws_security_group.alb_sg.id
  description                  = "Allow HTTP From VPC LINK SG"
  referenced_security_group_id = aws_security_group.vpclinkv2_sg.id
  ip_protocol                  = "tcp"
  from_port                    = "80"
  to_port                      = "80"
  tags = {
    Name = "http-from-vpclinksg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_sg_allow_https_from_vpclinksg" {
  security_group_id            = aws_security_group.alb_sg.id
  description                  = "Allow HTTPS From VPC LINK SG"
  referenced_security_group_id = aws_security_group.vpclinkv2_sg.id
  ip_protocol                  = "tcp"
  from_port                    = "443"
  to_port                      = "443"
  tags = {
    Name = "https-from-vpclinksg"
  }
}

resource "aws_vpc_security_group_egress_rule" "vpclinkv2_sg_allow_http_to_albsg" {
  security_group_id            = aws_security_group.vpclinkv2_sg.id
  description                  = "Allow HTTP To ALB SG"
  referenced_security_group_id = aws_security_group.alb_sg.id
  ip_protocol                  = "tcp"
  from_port                    = "80"
  to_port                      = "80"
  tags = {
    Name = "http-to-albsg"
  }
}

resource "aws_vpc_security_group_egress_rule" "vpclinkv2_sg_allow_https_to_albsg" {
  security_group_id            = aws_security_group.vpclinkv2_sg.id
  description                  = "Allow HTTPS To ALB SG"
  referenced_security_group_id = aws_security_group.alb_sg.id
  ip_protocol                  = "tcp"
  from_port                    = "443"
  to_port                      = "443"
  tags = {
    Name = "https-to-albsg"
  }
}