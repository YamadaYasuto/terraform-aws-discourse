#バケットポリシー用にELBアカウントIDの取得
data "aws_elb_service_account" "this" {}

#バケットポリシー用にAWSアカウントIDの取得
data "aws_caller_identity" "this" {}

# ALBアクセスログのバケットポリシー用IAM ポリシーの作成
data "aws_iam_policy_document" "this" {
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_elb_service_account.this.id}:root"]
    }
    actions   = ["s3:PutObject"]
    resources = ["${var.s3_bucket_arn}/*"]
  }
}

# バケットポリシーの作成・アタッチ
resource "aws_s3_bucket_policy" "this" {
  bucket = var.s3_bucket_id
  policy = data.aws_iam_policy_document.this.json
}

# ALBの作成
resource "aws_lb" "this" {
  name               = var.alb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_group_id]
  subnets            = var.subnets

  access_logs {
    bucket  = var.s3_bucket_id
    prefix  = "alb"
    enabled = true
  }
}

# ターゲットグループの作成
resource "aws_lb_target_group" "this" {
  name        = var.tg_name
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    interval            = 30
    path                = "/"
    port                = 80
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
    matcher             = 200
  }
}

# ターゲットグループにターゲットを関連付け
resource "aws_lb_target_group_attachment" "this" {
  target_group_arn = aws_lb_target_group.this.arn
  target_id        = var.target_ip
  port             = aws_lb_target_group.this.port
}

# HTTPSリスナー作成 -> 全ての条件を満たさない場合アクセス拒否
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.this.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = var.cert_arn_alb

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "unauthorized access"
      status_code  = "403"
    }
  }
}

# HTTPリスナー作成 -> HTTPSにリダイレクト
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      protocol    = "HTTPS"
      port        = "443"
      status_code = "HTTP_301"
    }
  }
}

# CloudFront カスタムヘッダーの値を取得する。
data "aws_ssm_parameter" "this" {
  name = var.ssm_param_custom_header_key
}

# カスタムヘッダーで ALB へのアクセスを CloudFront のみに制御する
resource "aws_lb_listener_rule" "header_condition" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 99

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }

  condition {
    http_header {
      http_header_name = var.ssm_param_custom_header_key
      values           = [data.aws_ssm_parameter.this.value]
    }
  }
}

# ALBのエイリアスレコード（A）
resource "aws_route53_record" "alb_alias" {

  zone_id = var.zone_id
  name    = var.relativ_domain_alb
  type    = "A"

  alias {
    name                   = aws_lb.this.dns_name
    zone_id                = aws_lb.this.zone_id
    evaluate_target_health = true
  }
}
