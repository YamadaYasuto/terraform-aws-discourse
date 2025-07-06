variable "domain_name" {
  description = "domain to be validated"
  type        = string
  default     = ""
}

variable "validate_subdomain" {
  description = "subdomain to be validated"
  type        = string
  default     = ""
}

variable "zone_id" {
  type        = string
  default     = ""
  description = "Route53 host zone ID to enable SES."
}

