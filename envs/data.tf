data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_partition" "current" {}

/************************************************************
Resource Policy - API Gateway
************************************************************/
data "aws_iam_policy_document" "regional_target_ssl_by_acm" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions   = ["execute-api:Invoke"]
    resources = ["${aws_api_gateway_rest_api.regional_target_ssl_by_acm.execution_arn}/*"]
    condition {
      test     = "IpAddress"
      variable = "aws:SourceIp"
      values   = var.source_ip
    }
  }
}