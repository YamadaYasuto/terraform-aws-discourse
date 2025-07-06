# ACMで証明書作成のリクエスト
resource "aws_acm_certificate" "cert" {
  domain_name       = "${var.validate_subdomain}.${var.domain_name}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# ドメイン検証用のレコード追加
resource "aws_route53_record" "acm_tls_cname" {
  # ドメイン名をキー、検証用レコードの設定値（キー：バリュー）のマップを生成
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  # 自動更新の有効化
  allow_overwrite = true

  # 作成レコードのパラメータセット
  name    = each.value.name
  records = [each.value.record]
  ttl     = 60
  type    = each.value.type
  zone_id = var.zone_id
}

# ドメイン検証
resource "aws_acm_certificate_validation" "domain" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.acm_tls_cname : record.fqdn]
}
