variable "bucket" {
  description = "backet name to store upload files"
  type        = string
  default     = ""
}

variable "enable_force_destroy" {
  description = "Boolean that indicates all objects (including any locked objects) should be deleted from the bucket when the bucket is destroyed so that the bucket can be destroyed without error"
  type        = bool
  default     = false
}
