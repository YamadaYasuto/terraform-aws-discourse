variable "zone_id" {
  type        = string
  default     = ""
  description = "Route53 host zone ID to enable SES."
}

variable "domain" {
  type        = string
  default     = ""
  description = "Domain name for SES."
}
