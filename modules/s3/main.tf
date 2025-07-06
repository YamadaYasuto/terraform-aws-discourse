# アップロードファイル用の S3 の作成
resource "aws_s3_bucket" "this" {
  bucket        = var.bucket
  force_destroy = var.enable_force_destroy
}

# S3 のバージョニングを有効化（社内自動削除ルール対応）
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Enabled"
  }
}
