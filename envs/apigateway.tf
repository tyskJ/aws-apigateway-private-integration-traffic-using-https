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
Regional REST API Gatway
************************************************************/
resource "aws_api_gateway_rest_api" "no_import" {
  name        = "regional-rest-api-no-import"
  description = "Regional REST API No Import"
  endpoint_configuration {
    ip_address_type = "ipv4"
    types           = ["REGIONAL"]
  }
  api_key_source               = "HEADER"
  disable_execute_api_endpoint = false
  tags = {
    Name = "regional-rest-api-no-import"
  }
}

/************************************************************
Resource Policy
************************************************************/
data "aws_iam_policy_document" "no_import" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions   = ["execute-api:Invoke"]
    resources = ["${aws_api_gateway_rest_api.no_import.execution_arn}/*"]
    condition {
      test     = "IpAddress"
      variable = "aws:SourceIp"
      values   = var.source_ip
    }
  }
}

resource "aws_api_gateway_rest_api_policy" "no_import" {
  rest_api_id = aws_api_gateway_rest_api.no_import.id
  policy      = data.aws_iam_policy_document.no_import.json
}

/************************************************************
Resource
************************************************************/
resource "aws_api_gateway_resource" "no_import_http" {
  rest_api_id = aws_api_gateway_rest_api.no_import.id
  parent_id   = aws_api_gateway_rest_api.no_import.root_resource_id
  path_part   = "http"
}
resource "aws_api_gateway_resource" "no_import_http_acm" {
  rest_api_id = aws_api_gateway_rest_api.no_import.id
  parent_id   = aws_api_gateway_resource.no_import_http.id
  path_part   = "acm"
}
resource "aws_api_gateway_resource" "no_import_http_pca" {
  rest_api_id = aws_api_gateway_rest_api.no_import.id
  parent_id   = aws_api_gateway_resource.no_import_http.id
  path_part   = "pca"
}
resource "aws_api_gateway_resource" "no_import_http_selfsigned" {
  rest_api_id = aws_api_gateway_rest_api.no_import.id
  parent_id   = aws_api_gateway_resource.no_import_http.id
  path_part   = "selfsigned"
}

resource "aws_api_gateway_resource" "no_import_https" {
  rest_api_id = aws_api_gateway_rest_api.no_import.id
  parent_id   = aws_api_gateway_rest_api.no_import.root_resource_id
  path_part   = "https"
}
resource "aws_api_gateway_resource" "no_import_https_acm" {
  rest_api_id = aws_api_gateway_rest_api.no_import.id
  parent_id   = aws_api_gateway_resource.no_import_https.id
  path_part   = "acm"
}
resource "aws_api_gateway_resource" "no_import_https_pca" {
  rest_api_id = aws_api_gateway_rest_api.no_import.id
  parent_id   = aws_api_gateway_resource.no_import_https.id
  path_part   = "pca"
}
resource "aws_api_gateway_resource" "no_import_https_selfsigned" {
  rest_api_id = aws_api_gateway_rest_api.no_import.id
  parent_id   = aws_api_gateway_resource.no_import_https.id
  path_part   = "selfsigned"
}

/************************************************************
Method - http/acm GET
************************************************************/
### Method Request
resource "aws_api_gateway_method" "no_import_http_acm_get" {
  rest_api_id          = aws_api_gateway_rest_api.no_import.id
  resource_id          = aws_api_gateway_resource.no_import_http_acm.id
  http_method          = "GET"
  authorization        = "NONE"
  authorization_scopes = []
  authorizer_id        = null
  api_key_required     = false
  request_validator_id = null
  operation_name       = null
  request_parameters   = {}
  request_models       = {}
}
### Integration Request
resource "aws_api_gateway_integration" "no_import_http_acm_get" {
  rest_api_id             = aws_api_gateway_rest_api.no_import.id
  resource_id             = aws_api_gateway_resource.no_import_http_acm.id
  http_method             = aws_api_gateway_method.no_import_http_acm_get.http_method
  type                    = "HTTP_PROXY"
  connection_type         = "VPC_LINK"
  response_transfer_mode  = "BUFFERED"
  integration_http_method = "GET"
  connection_id           = aws_apigatewayv2_vpc_link.this.id
  integration_target      = aws_lb.private_alb.arn
  uri                     = "http://acm.${var.domain_name}"
  timeout_milliseconds    = 29000
  cache_key_parameters    = []
  request_parameters      = {}
  content_handling        = null
  credentials             = null
  passthrough_behavior    = "WHEN_NO_MATCH"
  request_templates       = {}
}
### Method Response
resource "aws_api_gateway_method_response" "no_import_http_acm_get" {
  rest_api_id = aws_api_gateway_rest_api.no_import.id
  resource_id = aws_api_gateway_resource.no_import_http_acm.id
  http_method = aws_api_gateway_method.no_import_http_acm_get.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {}
}

/************************************************************
Method - http/pca GET
************************************************************/
### Method Request
resource "aws_api_gateway_method" "no_import_http_pca_get" {
  rest_api_id          = aws_api_gateway_rest_api.no_import.id
  resource_id          = aws_api_gateway_resource.no_import_http_pca.id
  http_method          = "GET"
  authorization        = "NONE"
  authorization_scopes = []
  authorizer_id        = null
  api_key_required     = false
  request_validator_id = null
  operation_name       = null
  request_parameters   = {}
  request_models       = {}
}
### Integration Request
resource "aws_api_gateway_integration" "no_import_http_pca_get" {
  rest_api_id             = aws_api_gateway_rest_api.no_import.id
  resource_id             = aws_api_gateway_resource.no_import_http_pca.id
  http_method             = aws_api_gateway_method.no_import_http_pca_get.http_method
  type                    = "HTTP_PROXY"
  connection_type         = "VPC_LINK"
  response_transfer_mode  = "BUFFERED"
  integration_http_method = "GET"
  connection_id           = aws_apigatewayv2_vpc_link.this.id
  integration_target      = aws_lb.private_alb.arn
  uri                     = "http://pca.${var.domain_name}"
  timeout_milliseconds    = 29000
  cache_key_parameters    = []
  request_parameters      = {}
  content_handling        = null
  credentials             = null
  passthrough_behavior    = "WHEN_NO_MATCH"
  request_templates       = {}
}
### Method Response
resource "aws_api_gateway_method_response" "no_import_http_pca_get" {
  rest_api_id = aws_api_gateway_rest_api.no_import.id
  resource_id = aws_api_gateway_resource.no_import_http_pca.id
  http_method = aws_api_gateway_method.no_import_http_pca_get.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {}
}

/************************************************************
Method - http/selfsigned GET
************************************************************/
### Method Request
resource "aws_api_gateway_method" "no_import_http_selfsigned_get" {
  rest_api_id          = aws_api_gateway_rest_api.no_import.id
  resource_id          = aws_api_gateway_resource.no_import_http_selfsigned.id
  http_method          = "GET"
  authorization        = "NONE"
  authorization_scopes = []
  authorizer_id        = null
  api_key_required     = false
  request_validator_id = null
  operation_name       = null
  request_parameters   = {}
  request_models       = {}
}
### Integration Request
resource "aws_api_gateway_integration" "no_import_http_selfsigned_get" {
  rest_api_id             = aws_api_gateway_rest_api.no_import.id
  resource_id             = aws_api_gateway_resource.no_import_http_selfsigned.id
  http_method             = aws_api_gateway_method.no_import_http_selfsigned_get.http_method
  type                    = "HTTP_PROXY"
  connection_type         = "VPC_LINK"
  response_transfer_mode  = "BUFFERED"
  integration_http_method = "GET"
  connection_id           = aws_apigatewayv2_vpc_link.this.id
  integration_target      = aws_lb.private_alb.arn
  uri                     = "http://selfsigned.${var.domain_name}"
  timeout_milliseconds    = 29000
  cache_key_parameters    = []
  request_parameters      = {}
  content_handling        = null
  credentials             = null
  passthrough_behavior    = "WHEN_NO_MATCH"
  request_templates       = {}
}
### Method Response
resource "aws_api_gateway_method_response" "no_import_http_selfsigned_get" {
  rest_api_id = aws_api_gateway_rest_api.no_import.id
  resource_id = aws_api_gateway_resource.no_import_http_selfsigned.id
  http_method = aws_api_gateway_method.no_import_http_selfsigned_get.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {}
}

/************************************************************
Method - https/acm GET
************************************************************/
### Method Request
resource "aws_api_gateway_method" "no_import_https_acm_get" {
  rest_api_id          = aws_api_gateway_rest_api.no_import.id
  resource_id          = aws_api_gateway_resource.no_import_https_acm.id
  http_method          = "GET"
  authorization        = "NONE"
  authorization_scopes = []
  authorizer_id        = null
  api_key_required     = false
  request_validator_id = null
  operation_name       = null
  request_parameters   = {}
  request_models       = {}
}
### Integration Request
resource "aws_api_gateway_integration" "no_import_https_acm_get" {
  rest_api_id             = aws_api_gateway_rest_api.no_import.id
  resource_id             = aws_api_gateway_resource.no_import_https_acm.id
  http_method             = aws_api_gateway_method.no_import_https_acm_get.http_method
  type                    = "HTTP_PROXY"
  connection_type         = "VPC_LINK"
  response_transfer_mode  = "BUFFERED"
  integration_http_method = "GET"
  connection_id           = aws_apigatewayv2_vpc_link.this.id
  integration_target      = aws_lb.private_alb.arn
  uri                     = "https://acm.${var.domain_name}"
  timeout_milliseconds    = 29000
  cache_key_parameters    = []
  request_parameters      = {}
  content_handling        = null
  credentials             = null
  passthrough_behavior    = "WHEN_NO_MATCH"
  request_templates       = {}
}
### Method Response
resource "aws_api_gateway_method_response" "no_import_https_acm_get" {
  rest_api_id = aws_api_gateway_rest_api.no_import.id
  resource_id = aws_api_gateway_resource.no_import_https_acm.id
  http_method = aws_api_gateway_method.no_import_https_acm_get.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {}
}

/************************************************************
Method - https/pca GET
************************************************************/
### Method Request
resource "aws_api_gateway_method" "no_import_https_pca_get" {
  rest_api_id          = aws_api_gateway_rest_api.no_import.id
  resource_id          = aws_api_gateway_resource.no_import_https_pca.id
  http_method          = "GET"
  authorization        = "NONE"
  authorization_scopes = []
  authorizer_id        = null
  api_key_required     = false
  request_validator_id = null
  operation_name       = null
  request_parameters   = {}
  request_models       = {}
}
### Integration Request
resource "aws_api_gateway_integration" "no_import_https_pca_get" {
  rest_api_id             = aws_api_gateway_rest_api.no_import.id
  resource_id             = aws_api_gateway_resource.no_import_https_pca.id
  http_method             = aws_api_gateway_method.no_import_https_pca_get.http_method
  type                    = "HTTP_PROXY"
  connection_type         = "VPC_LINK"
  response_transfer_mode  = "BUFFERED"
  integration_http_method = "GET"
  connection_id           = aws_apigatewayv2_vpc_link.this.id
  integration_target      = aws_lb.private_alb.arn
  uri                     = "https://pca.${var.domain_name}"
  timeout_milliseconds    = 29000
  cache_key_parameters    = []
  request_parameters      = {}
  content_handling        = null
  credentials             = null
  passthrough_behavior    = "WHEN_NO_MATCH"
  request_templates       = {}
}
### Method Response
resource "aws_api_gateway_method_response" "no_import_https_pca_get" {
  rest_api_id = aws_api_gateway_rest_api.no_import.id
  resource_id = aws_api_gateway_resource.no_import_https_pca.id
  http_method = aws_api_gateway_method.no_import_https_pca_get.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {}
}

/************************************************************
Method - https/selfsigned GET
************************************************************/
### Method Request
resource "aws_api_gateway_method" "no_import_https_selfsigned_get" {
  rest_api_id          = aws_api_gateway_rest_api.no_import.id
  resource_id          = aws_api_gateway_resource.no_import_https_selfsigned.id
  http_method          = "GET"
  authorization        = "NONE"
  authorization_scopes = []
  authorizer_id        = null
  api_key_required     = false
  request_validator_id = null
  operation_name       = null
  request_parameters   = {}
  request_models       = {}
}
### Integration Request
resource "aws_api_gateway_integration" "no_import_https_selfsigned_get" {
  rest_api_id             = aws_api_gateway_rest_api.no_import.id
  resource_id             = aws_api_gateway_resource.no_import_https_selfsigned.id
  http_method             = aws_api_gateway_method.no_import_https_selfsigned_get.http_method
  type                    = "HTTP_PROXY"
  connection_type         = "VPC_LINK"
  response_transfer_mode  = "BUFFERED"
  integration_http_method = "GET"
  connection_id           = aws_apigatewayv2_vpc_link.this.id
  integration_target      = aws_lb.private_alb.arn
  uri                     = "https://selfsigned.${var.domain_name}"
  timeout_milliseconds    = 29000
  cache_key_parameters    = []
  request_parameters      = {}
  content_handling        = null
  credentials             = null
  passthrough_behavior    = "WHEN_NO_MATCH"
  request_templates       = {}
}
### Method Response
resource "aws_api_gateway_method_response" "no_import_https_selfsigned_get" {
  rest_api_id = aws_api_gateway_rest_api.no_import.id
  resource_id = aws_api_gateway_resource.no_import_https_selfsigned.id
  http_method = aws_api_gateway_method.no_import_https_selfsigned_get.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {}
}

/************************************************************
Deployment
************************************************************/
resource "aws_api_gateway_deployment" "no_import_deployment" {
  for_each = toset(var.deployments_no_import)
  depends_on = [
    aws_api_gateway_method.no_import_proxy_any,
    aws_api_gateway_integration.no_import_proxy_any,
    aws_api_gateway_method_response.no_import_proxy_any
  ]
  rest_api_id = aws_api_gateway_rest_api.no_import.id
  description = "Deployment Version ${each.key}"
  lifecycle {
    create_before_destroy = true
  }
}

/************************************************************
Stage
************************************************************/
resource "aws_api_gateway_stage" "no_import_stage" {
  rest_api_id           = aws_api_gateway_rest_api.no_import.id
  deployment_id         = aws_api_gateway_deployment.no_import_deployment[local.deployment_no_import].id
  stage_name            = "prod"
  description           = "Production Stage"
  cache_cluster_enabled = false
  tags = {
    Name = "prod"
  }
}
