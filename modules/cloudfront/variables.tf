variable "ssm_param_custom_header_key" {
  description = "Parameter Key for custom header of CloudFront in SSM Parameter Store"
  type        = string
  default     = ""
}

variable "root_domain" {
  description = "root-domain"
  type        = string
  default     = ""
}

variable "relative_domain_cloudfront" {
  description = "sub-domain for CloudFront"
  type        = string
  default     = ""
}

variable "relativ_domain_alb" {
  description = "domain name of alias record"
  type        = string
  default     = ""
}

variable "origin_id" {
  description = "id for origin"
  type        = string
  default     = ""
}

variable "function_arn" {
  type    = string
  default = ""
}

variable "cert_arn_cloudfront" {
  description = "arn of cert for cloudfront"
  type        = string
  default     = ""
}

variable "zone_id" {
  description = "zone id for alias record to"
  type        = string
  default     = ""
}

variable "bucket_domain_name" {
  description = "domain name of backet for cloudfront access log"
  type        = string
  default     = ""
}

variable "s3_bucket_arn" {
  description = "domain arn of backet for cloudfront access log"
  type        = string
  default     = ""
}

variable "s3_bucket_id" {
  description = "domain id of backet for cloudfront access log"
  type        = string
  default     = ""
}
