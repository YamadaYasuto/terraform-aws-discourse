terraform {
  backend "s3" {
    bucket       = "tom-backet"
    key          = "terraform/terraform-prod.tfstate"
    region       = "ap-northeast-1"
    use_lockfile = true
  }
}
