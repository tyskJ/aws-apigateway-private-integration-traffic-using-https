variable "source_ip" {
  type = list(string)
}

variable "domain_name" {
  type = string
}

variable "public_hostedzone_id" {
  type = string
}

variable "deployments_no_import" {
  description = "List of deployments no import api, this is used to build the deployment ids"
  default     = ["v1"]
  type        = list(string)
}

variable "rollback_no_import" {
  description = "Deployment RollBack Flag no import api"
  default     = false
  type        = bool
}

variable "reverse_ids_no_import" {
  description = "Set RollBack Deployment generation number no import api"
  default     = 1
  type        = number
  validation {
    condition     = length(var.deployments_no_import) >= var.reverse_ids_no_import
    error_message = "Must less than deployments length minus 1"
  }
}