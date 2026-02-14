locals {
  account_id     = data.aws_caller_identity.current.account_id
  region_name    = data.aws_region.current.region
  partition_name = data.aws_partition.current.partition
}

locals {
  last_deployment_no_import = element(var.deployments_no_import, length(var.deployments_no_import) - 1)
  deployment_no_import      = var.rollback_no_import == true ? element(var.deployments_no_import, length(var.deployments_no_import) - var.reverse_ids_no_import) : local.last_deployment_no_import
}
