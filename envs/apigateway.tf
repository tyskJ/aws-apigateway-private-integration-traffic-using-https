/************************************************************
VPC Link V2
************************************************************/
resource "aws_apigatewayv2_vpc_link" "this" {
  name = "vpc-link-v2"
  security_group_ids = [
    aws_security_group.vpclinkv2_sg.id
  ]
  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_c.id
  ]
  tags = {
    Name = "vpc-link-v2"
  }
}