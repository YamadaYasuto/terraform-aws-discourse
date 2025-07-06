# プライベートサブネット上にサブネットグループを作成
resource "aws_db_subnet_group" "this" {
  name       = var.db_subnet_group
  subnet_ids = var.subnet_ids
}

resource "aws_db_parameter_group" "this" {
  name   = var.db_parameter_group
  family = "postgres16"

  # Logs each successful connection.
  parameter {
    name  = "log_connections"
    value = "1"
  }

  # Logs end of a session, including duration.
  parameter {
    name  = "log_disconnections"
    value = "1"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# SSMパラメータストアからDBパスワードを取得
data "aws_ssm_parameter" "this" {
  name = var.ssm_param_db_passwd_key
}

resource "aws_db_instance" "this" {
  identifier                      = var.db_identifier
  instance_class                  = "db.t3.medium"
  db_subnet_group_name            = aws_db_subnet_group.this.name
  storage_encrypted               = true
  parameter_group_name            = aws_db_parameter_group.this.name
  apply_immediately               = true
  vpc_security_group_ids          = var.security_group_id # リストが期待値
  skip_final_snapshot             = true                  # スナップショットなしで削除を許可
  enabled_cloudwatch_logs_exports = ["postgresql"]        # CloudWatch-logsへのSQLログ出力

  # 分岐: snapshot_id が指定されていなければRDSを新規作成、指定されていれば復元
  snapshot_identifier = var.snapshot_id == "" ? null : var.snapshot_id

  # RDSを新規作成するときは以下のパラメータで作成
  engine            = var.snapshot_id == "" ? "postgres" : null
  engine_version    = var.snapshot_id == "" ? "16.8" : null
  allocated_storage = var.snapshot_id == "" ? 50 : null
  username          = var.snapshot_id == "" ? "postgres" : null
  password          = var.snapshot_id == "" ? data.aws_ssm_parameter.this.value : null
}

