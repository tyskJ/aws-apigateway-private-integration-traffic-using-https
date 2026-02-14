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

/************************************************************
Resource Policy
************************************************************/
resource "aws_api_gateway_rest_api_policy" "resource_policy_for_regional_target_ssl_by_acm" {
  rest_api_id = aws_api_gateway_rest_api.regional_target_ssl_by_acm.id
  policy      = data.aws_iam_policy_document.regional_target_ssl_by_acm.json
}

/************************************************************
Resource
************************************************************/
resource "aws_api_gateway_resource" "regional_target_ssl_by_acm_proxy" {
  rest_api_id = aws_api_gateway_rest_api.regional_target_ssl_by_acm.id
  parent_id   = aws_api_gateway_rest_api.regional_target_ssl_by_acm.root_resource_id
  path_part   = "{proxy+}"
}

/************************************************************
Method
************************************************************/
### Method Request
resource "aws_api_gateway_method" "regional_target_ssl_by_acm_proxy_any" {
  rest_api_id          = aws_api_gateway_rest_api.regional_target_ssl_by_acm.id
  resource_id          = aws_api_gateway_resource.regional_target_ssl_by_acm_proxy.id
  http_method          = "ANY"
  authorization        = "NONE"
  authorization_scopes = []
  authorizer_id        = null
  api_key_required     = false
  request_validator_id = null
  operation_name       = null
  request_parameters = {
    "method.request.path.proxy" = true
  }
  request_models = {}
}

### Integration Request
resource "aws_api_gateway_integration" "regional_target_ssl_by_acm_proxy_any" {
  rest_api_id             = aws_api_gateway_rest_api.regional_target_ssl_by_acm.id
  resource_id             = aws_api_gateway_resource.regional_target_ssl_by_acm_proxy.id
  http_method             = aws_api_gateway_method.regional_target_ssl_by_acm_proxy_any.http_method
  type                    = "HTTP_PROXY"
  connection_type         = "VPC_LINK"
  response_transfer_mode  = "BUFFERED"
  integration_http_method = "ANY"
  connection_id           = aws_apigatewayv2_vpc_link.this.id
  integration_target      = aws_lb.private_alb.arn
  uri                     = "http://${aws_lb.private_alb.dns_name}"
  timeout_milliseconds    = 29000
  cache_key_parameters    = ["method.request.path.proxy"]
  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
  content_handling     = null
  credentials          = null
  passthrough_behavior = "WHEN_NO_MATCH"
  request_templates    = {}
}

### Method Response
resource "aws_api_gateway_method_response" "regional_target_ssl_by_acm_proxy_any" {
  rest_api_id = aws_api_gateway_rest_api.regional_target_ssl_by_acm.id
  resource_id = aws_api_gateway_resource.regional_target_ssl_by_acm_proxy.id
  http_method = aws_api_gateway_method.regional_target_ssl_by_acm_proxy_any.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {}
}

/************************************************************
Deployment
************************************************************/
resource "aws_api_gateway_deployment" "regional_target_ssl_by_acm_deployment" {
  for_each = toset(var.deployments)
  depends_on = [
    aws_api_gateway_method.regional_target_ssl_by_acm_proxy_any,
    aws_api_gateway_integration.regional_target_ssl_by_acm_proxy_any,
    aws_api_gateway_method_response.regional_target_ssl_by_acm_proxy_any
  ]
  rest_api_id = aws_api_gateway_rest_api.regional_target_ssl_by_acm.id
  description = "Deployment Version ${each.key}"
  lifecycle {
    create_before_destroy = true
  }
}

/************************************************************
Stage
************************************************************/
resource "aws_api_gateway_stage" "regional_target_ssl_by_acm_stage" {
  rest_api_id           = aws_api_gateway_rest_api.regional_target_ssl_by_acm.id
  deployment_id         = aws_api_gateway_deployment.regional_target_ssl_by_acm_deployment[local.deployment].id
  stage_name            = "prod"
  description           = "Production Stage"
  cache_cluster_enabled = false
  tags = {
    Name = "prod"
  }
}