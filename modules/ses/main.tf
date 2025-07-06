# SES ドメイン ID の作成
resource "aws_ses_domain_identity" "ses_domain" {
  domain = var.domain
}

# ドメイン検証して DKIM トークンを発行
resource "aws_ses_domain_dkim" "ses_dkim" {
  domain = aws_ses_domain_identity.ses_domain.domain
}

# DKIM の CNAME レコードを Route 53 に登録
resource "aws_route53_record" "ses_dkim_cname" {
  count   = 3
  zone_id = var.zone_id
  name    = "${element(aws_ses_domain_dkim.ses_dkim.dkim_tokens, count.index)}._domainkey.${aws_ses_domain_identity.ses_domain.domain}"
  type    = "CNAME"
  ttl     = "600"
  records = ["${element(aws_ses_domain_dkim.ses_dkim.dkim_tokens, count.index)}.dkim.amazonses.com"]
}

# SPF（TXT レコード）
resource "aws_route53_record" "ses_spf_txt" {
  zone_id = var.zone_id
  name    = aws_ses_domain_identity.ses_domain.domain
  type    = "TXT"
  ttl     = "600"
  records = ["v=spf1 include:amazonses.com ~all"]
}

# DMARC（TXT レコード）
resource "aws_route53_record" "ses_dmarc_txt" {
  zone_id = var.zone_id
  name    = "_dmarc.${aws_ses_domain_identity.ses_domain.domain}"
  type    = "TXT"
  ttl     = "600"
  records = ["v=DMARC1; p=none; pct=100"]
}
