variable "s3_bucket_arn" {
  description = "backet arn to store access log"
  type        = string
  default     = ""
}

variable "s3_bucket_id" {
  description = "backet id to store access log"
  type        = string
  default     = ""
}

variable "enable_force_destroy_alb_accesslog" {
  description = "Boolean that indicates all objects (including any locked objects) should be deleted from the bucket when the bucket is destroyed so that the bucket can be destroyed without error"
  type        = bool
  default     = false
}

variable "alb_name" {
  description = "name of application load balancer"
  type        = string
  default     = ""
}

variable "security_group_id" {
  description = "security group id for ALB"
  type        = string
  default     = ""
}

variable "subnets" {
  description = "name of application load balancer"
  type        = list(any)
  default     = []
}

variable "tg_name" {
  description = "name of target group for application load balancer"
  type        = string
  default     = ""
}

variable "vpc_id" {
  description = "vpc id for target group"
  type        = string
  default     = null
}

variable "target_ip" {
  description = "target ip address for ALB"
  type        = string
  default     = ""
}

variable "cert_arn_alb" {
  description = "arn of cert for alb"
  type        = string
  default     = ""
}

variable "ssm_param_custom_header_key" {
  description = "Parameter Key for custom header of CloudFront in SSM Parameter Store"
  type        = string
  default     = ""
}

variable "zone_id" {
  description = "zone id for alias record to"
  type        = string
  default     = ""
}

variable "relativ_domain_alb" {
  description = "domain name of alias record"
  type        = string
  default     = ""
}

