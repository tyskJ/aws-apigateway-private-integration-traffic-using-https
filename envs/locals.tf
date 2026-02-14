locals {
  account_id     = data.aws_caller_identity.current.account_id
  region_name    = data.aws_region.current.region
  partition_name = data.aws_partition.current.partition
}

locals {
  last_deployment = element(var.deployments, length(var.deployments) - 1)
  deployment      = var.rollback == true ? element(var.deployments, length(var.deployments) - var.reverse_ids) : local.last_deployment
}
