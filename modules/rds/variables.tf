variable "db_identifier" {
  description = "name for RDS instance"
  type        = string
  default     = ""
}

variable "db_subnet_group" {
  description = "subnet group name for RDS"
  type        = string
  default     = ""
}

variable "subnet_ids" {
  description = "A list of private subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "db_parameter_group" {
  description = "parameter group for RDS"
  type        = string
  default     = ""
}

variable "ssm_param_db_passwd_key" {
  description = "db key of password in ssm parameter store"
  type        = string
  default     = ""
}

variable "security_group_id" {
  description = "A list of security group id"
  type        = list(string)
  default     = []
}

variable "snapshot_id" {
  description = "snapshot-id if you need"
  type        = string
  default     = ""
}
