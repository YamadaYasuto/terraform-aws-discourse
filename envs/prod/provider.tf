# デフォルトプロバイダー
provider "aws" {
  region = var.default_region

  # 作成する AWS リソースにデフォルトでタグを付与する。
  default_tags {
    tags = {
      Environment = var.environment
      Terraform   = "True"
      Owner       = var.owner
      Project     = var.project
      Contact     = var.contact
    }
  }
}

# CloudFront関連のプロバイダー
provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"

  # 作成する AWS リソースにデフォルトでタグを付与する。
  default_tags {
    tags = {
      Environment = var.environment
      Terraform   = "True"
      Owner       = var.owner
      Project     = var.project
      Contact     = var.contact
    }
  }
}
