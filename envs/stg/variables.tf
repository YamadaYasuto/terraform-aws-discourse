################################################################################
# provider 用の変数
################################################################################
variable "default_region" {
  description = "default region"
  type        = string
  default     = ""
}

variable "environment" {
  description = "environmet"
  type        = string
  default     = ""
}

variable "owner" {
  description = "resource owner"
  type        = string
  default     = ""
}

variable "project" {
  description = "your project name"
  type        = string
  default     = ""
}

variable "contact" {
  description = "e-mail"
  type        = string
  default     = ""
}

################################################################################
# vpc モジュール用の変数
################################################################################

variable "vpc_name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
  default     = ""
}

variable "cidr" {
  description = "The IPv4 CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "A list of availability zones names or ids in the region"
  type        = list(string)
  default     = []
}

variable "private_subnets" {
  description = "A list of private subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "public_subnets" {
  description = "A list of public subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "enable_nat_gateway" {
  description = "Should be true if you want to provision NAT Gateways for each of your private networks"
  type        = bool
  default     = false
}

variable "single_nat_gateway" {
  description = "Should be true if you want to provision a single shared NAT Gateway across all of your private networks"
  type        = bool
  default     = false
}

################################################################################
# Route53 モジュール用の変数
################################################################################

variable "root_zone_domain" {
  description = "Name of DNS zone"
  type        = string
  default     = ""
}

variable "sub_zone_domain" {
  description = "Name of DNS zone"
  type        = string
  default     = null
}

################################################################################
# SES モジュール用の変数
################################################################################

# 特になし

################################################################################
# ACM モジュール用の変数（CloudFront用 us-east-1）
################################################################################

variable "relative_domain_cloudfront" {
  description = "sub domain of CloudFront"
  type        = string
  default     = ""
}

################################################################################
# ACM モジュール用の変数（alb用 ap-northeast-1）
################################################################################

variable "relativ_domain_alb" {
  description = "sub domain of alb"
  type        = string
  default     = ""
}

################################################################################
# Security Group モジュール用の変数（ALB用）
################################################################################

variable "sg_name_alb" {
  description = "name of security group for application load balancer"
  type        = string
  default     = ""
}

################################################################################
# Security Group モジュール用の変数（EC2用）
################################################################################

variable "sg_name_ec2" {
  description = "name of security group for ec2"
  type        = string
  default     = ""
}

################################################################################
# Security Group モジュール用の変数（RDS用）
################################################################################

variable "sg_name_rds" {
  description = "name of security group for rds"
  type        = string
  default     = ""
}

################################################################################
# EC2 モジュール用の変数
################################################################################

variable "ec2_private_ip" {
  description = "ip address for ec2"
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

################################################################################
# ALB モジュール用の変数
################################################################################

variable "alb_name" {
  description = "name of application load balancer"
  type        = string
  default     = ""
}

variable "tg_name" {
  description = "name of target group for application load balancer"
  type        = string
  default     = ""
}

variable "ssm_param_custom_header_key" {
  description = "Parameter Key for custom header of CloudFront in SSM Parameter Store"
  type        = string
  sensitive   = true
  default     = ""
}

################################################################################
# CloudFront モジュール用の変数
################################################################################

variable "origin_id" {
  description = "id for origin"
  type        = string
  default     = ""
}

################################################################################
# CloudFunctions モジュール用の変数
################################################################################

variable "basicauth_username" {
  type    = string
  default = ""
}

variable "basicauth_password" {
  type      = string
  sensitive = true
  default   = ""
}

################################################################################
# S3 モジュール用の変数( CloudFront アクセスログ保管用のS3)
################################################################################

variable "cloudfront_accesslog" {
  description = "backet name to store accesslog for cloudfront"
  type        = string
  default     = ""
}

variable "enable_force_destroy_cloudfront_accesslog" {
  description = "Boolean that indicates all objects (including any locked objects) should be deleted from the bucket when the bucket is destroyed so that the bucket can be destroyed without error"
  type        = bool
  default     = false
}

################################################################################
# S3 モジュール用の変数（ALB アクセスログ）
################################################################################

variable "alb_accesslog" {
  description = "backet name to store accesslog for ALB"
  type        = string
  default     = ""
}

variable "enable_force_destroy_alb_accesslog" {
  description = "Boolean that indicates all objects (including any locked objects) should be deleted from the bucket when the bucket is destroyed so that the bucket can be destroyed without error"
  type        = bool
  default     = false
}

################################################################################
# RDS モジュール用の変数
################################################################################

variable "db_identifier" {
  description = "name for RDS instance"
  type        = string
  default     = ""
}

variable "db_subnet_group" {
  description = "subnet group for RDS"
  type        = string
  default     = ""
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

variable "db_name" {
  description = "name for RDS instance"
  type        = string
  default     = ""
}

variable "snapshot_id" {
  description = "snapshot-id if you need"
  type        = string
  default     = ""
}