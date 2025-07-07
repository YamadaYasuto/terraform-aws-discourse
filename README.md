## ⚠️ このリポジトリについて
このリポジトリは、TerraformとAWSを用いたインフラ構築の学習、および自身の技術ポートフォリオとして作成したものです。

実際のプロダクション環境での利用を想定したものではなく、あくまで技術デモンストレーションを目的としています。簡略化のため、一部のセキュリティ設定が省略されている箇所がありますので、ご注意ください。

コードに関するご意見や改善点などがありましたら、お気軽にご連絡いただけると幸いです。

## Discourse on AWS (IaC)
このリポジトリは、オープンソースのフォーラムソフトウェアDiscourseをAWS上に構築するためのTerraformコードです。
VPC、EC2、RDS、ALB、CloudFrontといった主要なAWSサービスをモジュール化し、prod環境とstg環境をディレクトリで分けて一つのリポジトリとして管理します。

## アーキテクチャ図

![terraform_discourse drawio](https://github.com/user-attachments/assets/f3502815-361c-4217-b3c7-d024b75fc570)

##  ディレクトリ構成
```
.
├── Makefile          # コマンドを簡略化するMakefile
├── envs              # 環境をディレクトリで分離
│   ├── prod          # 本番環境用
│   └── stg           # ステージング環境用
└── modules           # 再利用可能なTerraformモジュール群
    ├── acm
    ├── alb
    ├── cloudfront
    ├── cloudfunction
    ├── ec2
    ├── rds
    ├── s3
    ├── security_group
    └── ses
```

## 主な特徴
- Infrastructure as Code: インフラ構成をTerraformでコード化。
- モジュール設計: 各AWSサービスを再利用可能なモジュールとして分割・管理。
- マルチ環境対応: stg (ステージング) と prod (本番) のような複数環境を容易に展開可能。
- セキュアな構成:
  - EC2とRDSをプライベートサブネットに配置。
  - 最小権限の原則に基づいたセキュリティグループ設定。
  - データベースのパスワードなどの機密情報をSSMパラメータストアで管理。
  - CloudFront FunctionsによるBasic認証。
  - ALBへの直接アクセスをカスタムヘッダーでCloudFrontからのみに制限。

## 前提条件
Terraformを実行する前に、以下の準備が必要です。

1. AWSアカウントと権限
   - AWSアカウント: 利用可能なAWSアカウントが必要です。
   - IAMユーザー/ロール: Terraformを実行するIAMユーザーまたはロールには、このプロジェクトで作成されるリソース（VPC, EC2, RDS, S3, CloudFront, Route53, ACM, SES等）を操作するための十分な権限が必要です。

2. 必要なツール
   - Terraform: v1.11.2で開発されています。

3. Terraform State管理用S3バケット
   - Terraformの状態（state）を管理するため、S3バケットを1つ手動で作成してください。

4. ドメイン
   - この構成ではRoute 53でDNSレコードを管理し、ACMでSSL証明書を発行します。事前にDiscourseで利用するドメイン名を取得し、AWS Route 53でホストゾーンを管理できる状態にしておいてください。

5. DiscourseサーバーのAMI
   - このTerraformコードは、Discourseがインストール済みのEC2インスタンスを起動します。そのため、Discourseのインストールと設定が完了したEC2インスタンスから、事前にAMI（Amazonマシンイメージ）を作成しておく必要があります。

6. 機密情報のパラメータストア格納
   - セキュリティ向上のため、パスワードなどの機密情報はコードに含めず、AWS Systems Manager (SSM) のパラメータストアで管理します。以下のパラメータをSecureStringタイプで事前に作成してください。
     - RDSデータベースのパスワード
     - CloudFront-ALB間で使用するカスタムヘッダーの値

## 利用ステップ

全ての前提条件が整ったら、以下の手順でインフラを構築します。

### ステップ1: リポジトリのクローンと移動
```
git clone ${REPO_URL}
```

### ステップ2: Terraform設定ファイルの編集
#### バックエンド設定の更新 (envs/stg/backend.tf)
`bucket`の値を、前提条件で作成したS3バケット名に書き換えます。

#### 変数ファイルの設定 (envs/stg/stg.auto.tfvars)
ご自身の環境に合わせて、以下の項目などを修正します。

- `root_zone_domain`, `sub_zone_domain`: 前提条件で用意したドメイン名

- `ami_id`: 前提条件で作成したDiscourseのAMI ID

- `ssm_param_db_passwd_key`など: 前提条件で作成したSSMパラメータの名前

### ステップ3: makeコマンドによるデプロイ
`Makefile`により、コマンドが簡略化されています。

#### ステージング環境（stg）での実行
`ENV`変数を指定しない場合、デフォルトで`stg`環境が対象となります。

```
# プロジェクトルートで以下を実行する

# 初期化
make init

# 実行計画の確認
make plan

# リソースの作成・適用
make apply

# リソースの削除
make destroy
```

#### 本番環境（prod）での実行
`prod`環境を対象にするには、各コマンドの末尾に `ENV=prod` を追加します。これにより、`envs/prod`ディレクトリを参照してTerraformが実行されます。

```
# プロジェクトルートで以下を実行する

# 本番環境の初期化
make init ENV=prod

# 本番環境の実行計画の確認
make plan ENV=prod

# 本番環境のリソースの作成・適用
make apply ENV=prod

# 本番環境のリソースの削除
make destroy ENV=prod
```

## discourseの画面イメージ

QAサイトのWEBアプリケーションです。
![1000001038](https://github.com/user-attachments/assets/228101f7-1bd5-4c0f-be8a-385e2ae09479)
![1000001039](https://github.com/user-attachments/assets/788eb99d-1dc0-427c-8b4f-f3ee8987c043)



