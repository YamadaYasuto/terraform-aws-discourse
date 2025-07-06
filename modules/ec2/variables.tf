variable "subnet_id" {
  description = "id of subnet for ENI"
  type        = string
  default     = ""
}

variable "ec2_private_ip" {
  description = "ip address for ec2"
  type        = string
  default     = ""
}

variable "security_group_id" {
  description = "security group id for ENI"
  type        = string
  default     = ""
}

variable "ami_id" {
  description = "id of ami for ALB target EC2"
  type        = string
  default     = ""
}

variable "iam_role_ec2" {
  description = "name of iam role for EC2"
  type        = string
  default     = ""
}

variable "ec2_name" {
  description = "tag-name of EC2"
  type        = string
  default     = ""
}
