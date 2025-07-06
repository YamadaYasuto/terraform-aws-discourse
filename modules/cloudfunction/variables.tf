variable "basicauth_username" {
  type    = string
  default = ""
}

variable "basicauth_password" {
  type      = string
  sensitive = true
  default   = ""
}
