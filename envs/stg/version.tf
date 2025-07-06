# provider plugin の指定
terraform {
  required_version = "=1.11.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}
