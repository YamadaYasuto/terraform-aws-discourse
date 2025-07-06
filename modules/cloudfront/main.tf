# SSMパラメータストアからALB用のカスタムヘッダー値を取得
data "aws_ssm_parameter" "this" {
  name = var.ssm_param_custom_header_key
}

# CloudFrontのディストリビューション作成
resource "aws_cloudfront_distribution" "this" {
  # CloudFrontのエイリアス名
  aliases         = ["${var.relative_domain_cloudfront}.${var.root_domain}"]
  enabled         = true                 # CloudFrontを有効化
  is_ipv6_enabled = false                # IPv6無効化
  comment         = "CloudFront for ALB" # コメント

  # オリジン設定
  origin {
    # オリジンのエイリアス名を指定
    domain_name = "${var.relativ_domain_alb}.${var.root_domain}"
    # ALBのidを指定
    origin_id = var.origin_id

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }

    # オリジンへの経路をCloudFrontのみに限定するためのヘッダー
    custom_header {
      name  = var.ssm_param_custom_header_key   # カスタムヘッダーキー
      value = data.aws_ssm_parameter.this.value # カスタムヘッダー値
    }
  }

  # デフォルトのリクエストの処理を定義
  default_cache_behavior {
    # 転送するオリジンを指定
    target_origin_id = var.origin_id

    # viewr <-> CloudFront間のプロトコル
    viewer_protocol_policy = "redirect-to-https"

    # 動的なサイトのためCRUDなどのメソッドも許可
    allowed_methods = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    # キャッシュはコンテンツの取得のみでよいため以下のメソッドをキャッシュ
    cached_methods = ["GET", "HEAD"]

    # キャッシュキーに全てのクエリ文字、Cookieと一部ヘッダーを指定するマネージドキャッシュポリシー
    # UseOriginCacheControlHeaders-QueryStrings
    cache_policy_id = "4cc15a8a-d715-48a4-82b8-cc0b614638fe"

    # キャッシュミスの場合に、ビューワーリクエストのすべての値 (ヘッダー、Cookie、クエリ文字列)をオリジンにリクエストするマネージドオリジンリクエストポリシー
    # AllViewer
    origin_request_policy_id = "216adef6-5c7f-47e4-b989-5492eafa07d3"

    # CloudFuncitonでBasic認証
    function_association {
      event_type   = "viewer-request"
      function_arn = var.function_arn
    }
  }

  # 日本だけ許可
  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["JP"]
    }
  }

  # SSL設定
  viewer_certificate {
    acm_certificate_arn      = var.cert_arn_cloudfront
    ssl_support_method       = "sni-only" # 独自ドメインかつ追加コスト発生なし
    minimum_protocol_version = "TLSv1.2_2021"
  }
}


# AWSアカウントIDの取得
data "aws_caller_identity" "this" {}

# CloudFrontアクセスログのバケットポリシー用IAMポリシーの作成
data "aws_iam_policy_document" "this" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
    actions   = ["s3:PutObject"]
    resources = ["${var.s3_bucket_arn}/*"]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.this.id]
    }
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:logs:us-east-1:${data.aws_caller_identity.this.id}:delivery-source:*"]
    }
  }
}

# アクセスログ用S3のバケットポリシーの作成・アタッチ
resource "aws_s3_bucket_policy" "this" {
  bucket = var.s3_bucket_id
  policy = data.aws_iam_policy_document.this.json
}

# CloudWatchAPIでアクセスログを有効化する
# 送付元リソース定義
resource "aws_cloudwatch_log_delivery_source" "this" {
  name         = "cloudfrot-accesslog-source"
  log_type     = "ACCESS_LOGS"
  resource_arn = aws_cloudfront_distribution.this.arn
}

# 送付先リソース定義
resource "aws_cloudwatch_log_delivery_destination" "this" {
  name          = "cloudfrot-accesslog-destination"
  output_format = "w3c"

  delivery_destination_configuration {
    # AWSコンソールの「送信先S3バケット」に相当
    destination_resource_arn = "${var.s3_bucket_arn}/accesslogs/"
  }
}

# Delivery定義
resource "aws_cloudwatch_log_delivery" "this" {
  delivery_source_name     = aws_cloudwatch_log_delivery_source.this.name
  delivery_destination_arn = aws_cloudwatch_log_delivery_destination.this.arn

  s3_delivery_configuration {
    suffix_path                 = "/{yyyy}/{MM}/{dd}/{HH}"
    enable_hive_compatible_path = false
  }
}

# CloudFrontのエイリアスレコード（A）
resource "aws_route53_record" "this" {

  # CloudFrontの営利差すレコードを登録するゾーン
  zone_id = var.zone_id
  # CloudFrontの相対ドメイン名
  name = var.relative_domain_cloudfront
  type = "A"
  alias {
    name                   = aws_cloudfront_distribution.this.domain_name
    zone_id                = aws_cloudfront_distribution.this.hosted_zone_id
    evaluate_target_health = true
  }
}
