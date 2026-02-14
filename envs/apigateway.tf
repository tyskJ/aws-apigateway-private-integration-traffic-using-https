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

/************************************************************
Regional REST API Gatway - target SSL by ACM
************************************************************/
resource "aws_api_gateway_rest_api" "regional_target_ssl_by_acm" {
  name        = "regional-rest-api-target-ssl-acm"
  description = "Regional REST API Target SSL By ACM"
  endpoint_configuration {
    ip_address_type = "ipv4"
    types           = ["REGIONAL"]
  }
  api_key_source               = "HEADER"
  disable_execute_api_endpoint = false
  tags = {
    Name = "regional-rest-api-target-ssl-acm"
  }
}