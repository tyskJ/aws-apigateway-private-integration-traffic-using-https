variable "source_ip" {
  type = list(string)
}

variable "domain_name" {
  type = string
}

variable "public_hostedzone_id" {
  type = string
}

variable "deployments" {
  description = "List of deployments, this is used to build the deployment ids"
  default     = ["v1", "v2"]
  type        = list(string)
}

variable "rollback" {
  description = "Deployment RollBack Flag"
  default     = false
  type        = bool
}

variable "reverse_ids" {
  description = "Set RollBack Deployment generation number"
  default     = 1
  type        = number
  validation {
    condition     = length(var.deployments) >= var.reverse_ids
    error_message = "Must less than deployments length minus 1"
  }
}