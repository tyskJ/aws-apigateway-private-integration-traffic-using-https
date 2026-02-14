terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  profile = "admin"
  region  = "ap-northeast-1"
  default_tags {
    tags = {
      Env                = "prd"
      System             = "aws-apigateway-private-integration-traffic-using-https"
      ManagedByTerraform = "true"
    }
  }
}