################################################################################
# local変数の宣言
################################################################################


locals {
  # パブリックホストゾーンの絶対ドメイン名（最後に'.'がつく）
  # レコードの値を設定する時には絶対ドメイン名が必要
  public_hostzone = join(".", [var.sub_zone_domain, var.root_zone_domain])

  # パブリックホストゾーンのFQDN（最後の'.'を除く）
  public_hostzone_ = trim(local.public_hostzone, ".")
}


################################################################################
# VPC、Subnet、NatGW 関連リソースの宣言
################################################################################

# vpc、private-subnet、public-subnet、nat-gwとrtbの作成
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.vpc_name
  cidr = var.cidr

  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = var.single_nat_gateway
}

################################################################################
# Route53 でサブドメインのパブリックホストゾーンの作成
################################################################################

# サブドメインの public hostzone の作成
module "zones" {
  source  = "terraform-aws-modules/route53/aws//modules/zones"
  version = "~> 3.0"

  # サブドメインを管理する public hostzone 名とその説明
  zones = {
    (local.public_hostzone) = {
      comment = "for discourse domain"
    }
  }
}

# 親ドメインの public hostzone にサブドメイン委任レコードを追加
module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "~> 3.0"

  # 親ドメインの public hostzone
  zone_name = var.root_zone_domain

  # サブドメイン委任レコードの追加
  records = [
    {
      name    = var.sub_zone_domain
      type    = "NS"
      ttl     = 172800
      records = module.zones.route53_zone_name_servers[local.public_hostzone]
    },
  ]

  depends_on = [
    module.zones
  ]
}

################################################################################
# SES ドメインID登録、DKIM検証、DKIM・SPF・DMARCレコード追加
################################################################################

# sesのドメインIDの登録、ドメイン検証、DKIM、SPF、DMARCレコード追加
module "ses" {
  source = "../../modules/ses"

  # ID登録・検証対象のドメイン
  domain = local.public_hostzone_

  # DKIM・SPF・DMARC レコード追加先 hostzone の id
  zone_id = module.zones.route53_zone_zone_id[local.public_hostzone]

  depends_on = [
    module.zones
  ]
}

################################################################################
# ACM ドメイン検証、証明書発行（CloudFront用 us-east-1）
################################################################################

module "acm_cloudfront" {
  source = "../../modules/acm"

  # CloudFrontに証明書を導入するため、リージョンを指定する。
  providers = {
    aws = aws.us-east-1
  }

  # ルートドメイン
  domain_name = local.public_hostzone_

  # 証明書をつくるサブドメイン
  validate_subdomain = var.relative_domain_cloudfront

  # 検証用レコード追加先ゾーンの指定
  zone_id = module.zones.route53_zone_zone_id[local.public_hostzone]

  depends_on = [
    module.zones
  ]
}

################################################################################
# ACM ドメイン検証、証明書発行（alb用 ap-northeast-1）
################################################################################

module "acm_alb" {
  source = "../../modules/acm"

  # ルートドメイン
  domain_name = local.public_hostzone_

  # ALBの相対ドメイン名
  validate_subdomain = var.relativ_domain_alb

  # 検証用レコード追加先ゾーンの指定
  zone_id = module.zones.route53_zone_zone_id[local.public_hostzone]

  depends_on = [
    module.zones
  ]
}

################################################################################
# セキュリティグループの作成（ALB用）
################################################################################

module "sg_alb" {
  source = "../../modules/security_group"

  # ALB用に作成するSGの名前
  sg_name = var.sg_name_alb

  # SGのVPC
  vpc_id = module.vpc.vpc_id

  # SGのインバウンドルール
  security_group_ingress_rules = {
    all_http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      description = "HTTP web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
    all_https = {
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      description = "HTTPS web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  # SGのアウトバウンドルール
  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = var.cidr
    }
  }

  depends_on = [
    module.vpc
  ]
}

################################################################################
# セキュリティグループの作成（EC2用）
################################################################################

module "sg_ec2" {
  source = "../../modules/security_group"

  # EC2用に作成するSGの名前
  sg_name = var.sg_name_ec2

  # SGのVPC
  vpc_id = module.vpc.vpc_id

  # SGのインバウンドルール
  security_group_ingress_rules = {
    from_http = {
      from_port                    = 80
      to_port                      = 80
      ip_protocol                  = "tcp"
      description                  = "HTTP web traffic"
      referenced_security_group_id = module.sg_alb.security_group_id
    }
  }

  # SGのアウトバウンドルール
  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
  depends_on = [
    module.vpc,
    module.sg_alb
  ]
}

################################################################################
# セキュリティグループの作成（RDS用）
################################################################################

module "sg_rds" {
  source = "../../modules/security_group"

  # RDS用に作成するSGの名前
  sg_name = var.sg_name_rds

  # SGのVPC
  vpc_id = module.vpc.vpc_id

  # SGのインバウンドルール
  security_group_ingress_rules = {
    from_ec2 = {
      from_port                    = 5432
      to_port                      = 5432
      ip_protocol                  = "tcp"
      description                  = "from EC2"
      referenced_security_group_id = module.sg_ec2.security_group_id
    }
  }

  # SGのアウトバウンドルール
  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  depends_on = [
    module.vpc,
    module.sg_alb,
    module.sg_ec2
  ]
}

################################################################################
# EC2 の作成
################################################################################

module "ec2" {
  source = "../../modules/ec2"

  # EC2起動サブネット
  subnet_id = module.vpc.private_subnets[0]

  # EC2用のENIに紐づけるプライベートIP
  ec2_private_ip = var.ec2_private_ip

  # EC2用のENIに紐づけるセキュリティグループ
  security_group_id = module.sg_ec2.security_group_id

  # EC2起動時に指定するAMI
  ami_id = var.ami_id

  # SSM用EC2のIAM Role
  iam_role_ec2 = var.iam_role_ec2

  # モック用EC2のタグ名
  ec2_name = var.ec2_name

  depends_on = [
    module.vpc,
    module.sg_ec2
  ]
}

################################################################################
# ALB と関連リソースの作成
################################################################################

module "alb" {
  source = "../../modules/alb"

  # ALBアクセスログのバケットArn（バケットポリシー作成用）
  s3_bucket_arn = module.s3_alb_accesslog.s3_bucket_arn

  # ALBアクセスログのバケットid（バケットポリシー作成用）
  s3_bucket_id = module.s3_alb_accesslog.s3_bucket_id

  # 作成するALBの名前
  alb_name = var.alb_name

  # ALBのセキュリティグループ
  security_group_id = module.sg_alb.security_group_id

  # ALBのサブネット
  subnets = module.vpc.public_subnets

  # ターゲットグループの名前
  tg_name = var.tg_name

  # ターゲットグループのVPC
  vpc_id = module.vpc.vpc_id

  # ターゲットグループのターゲットIPアドレス
  target_ip = module.ec2.eni_ip

  # ALB用の証明書
  cert_arn_alb = module.acm_alb.aws_acm_certificate_arn

  # CloudFrontカスタムヘッダー値のSSMパラメーターキー
  ssm_param_custom_header_key = var.ssm_param_custom_header_key

  # ALBのエイリアスレコードを登録するゾーン
  zone_id = module.zones.route53_zone_zone_id[local.public_hostzone]

  # ALBの相対ドメイン名
  relativ_domain_alb = var.relativ_domain_alb

  depends_on = [
    module.vpc,
    module.sg_alb,
    module.zones,
    module.ec2,
    module.acm_alb,
    module.s3_alb_accesslog
  ]
}

################################################################################
# S3 の作成（ALB アクセスログ）
################################################################################

module "s3_alb_accesslog" {
  source = "../../modules/s3"

  # バケット名
  bucket = var.alb_accesslog

  # S3オブジェクト強制削除の有効化
  enable_force_destroy = var.enable_force_destroy_alb_accesslog
}


################################################################################
# CloudFront と関連リソースの作成
################################################################################

module "cloudfront" {
  source = "../../modules/cloudfront"

  # CloudFrontをサポートしているリージョンを指定する。
  providers = {
    aws = aws.us-east-1
  }

  # CloudFrontカスタムヘッダー値のSSMパラメーターキー
  ssm_param_custom_header_key = var.ssm_param_custom_header_key

  # パブリックドゾーンドメイン
  root_domain = local.public_hostzone_

  # CloudFrontの相対ドメイン名
  relative_domain_cloudfront = var.relative_domain_cloudfront

  # ALBの相対ドメイン名（originの指定で使用）
  relativ_domain_alb = var.relativ_domain_alb

  # オリジンとなるALBのIDを指定
  origin_id = var.origin_id

  # Fuction Arn
  function_arn = module.cloudfunction.function_arn

  # CloudFront用の証明書
  cert_arn_cloudfront = module.acm_cloudfront.aws_acm_certificate_arn

  # CloudFrontのエイリアスレコードを登録するホストゾーンのID
  zone_id = module.zones.route53_zone_zone_id[local.public_hostzone]

  # CloudFrontのアクセスログのバケットのARN
  s3_bucket_arn = module.s3_cloudfront_accesslog.s3_bucket_arn

  # CloudFrontのアクセスログのバケットのID
  s3_bucket_id = module.s3_cloudfront_accesslog.s3_bucket_id

  # CloudFrontカスタムドメインの証明書の発行を待つ。
  depends_on = [
    module.acm_cloudfront,
    module.cloudfunction,
    module.zones,
    module.s3_cloudfront_accesslog
  ]
}

################################################################################
# CloudFunctions の作成(basic認証)
################################################################################

module "cloudfunction" {
  source = "../../modules/cloudfunction"

  # ベーシック認証のユーザー名
  basicauth_username = var.basicauth_username

  # ベーシック認証のパスワード
  basicauth_password = var.basicauth_password
}

################################################################################
# S3 の作成( CloudFront アクセスログ保管用のS3)
################################################################################

module "s3_cloudfront_accesslog" {
  source = "../../modules/s3"

  # CloudFrontをサポートしているリージョンを指定する。
  providers = {
    aws = aws.us-east-1
  }

  # バケット名
  bucket = var.cloudfront_accesslog

  # S3オブジェクト強制削除の有効化
  enable_force_destroy = var.enable_force_destroy_cloudfront_accesslog
}

################################################################################
# RDS の作成
################################################################################

module "RDS" {
  source = "../../modules/rds"

  # DB 識別子
  db_identifier = var.db_identifier

  # DBサブネットグループ名
  db_subnet_group = var.db_subnet_group

  # DBサブネットグループの指定
  subnet_ids = module.vpc.private_subnets

  # DBパラメータグループ
  db_parameter_group = var.db_parameter_group

  # DBパスワードのキー名（SSMパラメータストア）
  ssm_param_db_passwd_key = var.ssm_param_db_passwd_key

  # RDSのセキュリティグループ
  security_group_id = [module.sg_rds.security_group_id]

  # スナップショットID (使う場合)
  snapshot_id = var.snapshot_id

  depends_on = [
    module.vpc,
    module.sg_alb,
    module.sg_ec2,

    module.ec2,
    module.sg_rds
  ]
}
