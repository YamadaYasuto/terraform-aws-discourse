terraform {
  backend "s3" {
    bucket       = "tom-backet"
    key          = "terraform/terraform-stg.tfstate"
    region       = "ap-northeast-1"
    use_lockfile = true
  }
}
