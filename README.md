# stuffed-toy-infra

「ぬいぐるみ」プロダクトの AWS インフラを Terraform で管理するリポジトリ。

## プロダクト概要

リアルタイム音声対話型のぬいぐるみ向けバックエンド・配信基盤。3 つのサービスが連携してフロントエンド UI から OpenAI Realtime API までの経路を構成する。

| サービス | リポジトリ | 役割 | 主な技術 |
|----------|------------|------|----------|
| **stuffed-toy-frontend** | [Devesion-inc/stuffed-toy-frontend](https://github.com/Devesion-inc/stuffed-toy-frontend) | Playground UI（静的サイト） | Bun + Next.js 16（`output: 'export'`） |
| **stuffed-toy-api** | [Devesion-inc/stuffed-toy-api](https://github.com/Devesion-inc/stuffed-toy-api) | REST + NDJSON streaming API（バックエンド） | Bun + Next.js 16 + Prisma 7 + PostgreSQL |
| **stuffed-toy-relay** | [Devesion-inc/stuffed-toy-relay](https://github.com/Devesion-inc/stuffed-toy-relay) | OpenAI Realtime API への WebSocket リレー | Bun ネイティブ |
| **stuffed-toy-tts**（GPU EC2）| [docker/tts/](docker/tts/)（リポジトリなし、infra リポ内で管理）| 音声合成（Aivis）。`.aivmx` モデルを焼き込んだ image を ECR push して EC2 で動かす | Aivis Engine（NVIDIA CUDA）|

外部依存:
- **OpenAI / Google Gemini** — AI 推論
- **PostgreSQL（Aurora から RDS Instance に切替済み）** — アプリケーション DB
- **AWS Secrets Manager** — 認証情報・API キー保管

---

## インフラ全体図

```
                                  ┌─────────────────────┐
                                  │  CloudFront (1個)   │
                                  │  WAF v2 (us-east-1) │
                                  └──┬───────────────┬──┘
                                     │               │
              ┌──────────────────────┼───────────────┼──────────────────────┐
              │ /api/*               │ /ws/* /healthz│ default              │
              ▼                      ▼               ▼                      │
       ┌─────────────┐       ┌──────────────┐    ┌───────────────────┐    │
       │ ALB (api)   │       │ ALB (relay)  │    │ S3 frontend       │    │
       │ HTTP 80     │       │ HTTP 80      │    │ (静的)            │    │
       └──────┬──────┘       └──────┬───────┘    │ + index_rewrite   │    │
              │ 3002                │ 3001       │   CF Function     │    │
              ▼                     ▼            └───────────────────┘    │
       ┌─────────────┐       ┌──────────────┐                              │
       │ ECS Fargate │       │ ECS Fargate  │                              │
       │ api task    │       │ relay task   │ ──────► VPC 内通信           │
       │ ARM64 Bun   │       │ ARM64 Bun    │            :10101            │
       └──────┬──────┘       └──────────────┘             ▼                │
              │                                  ┌──────────────────┐      │
              ▼                                  │ EC2 g4dn.xlarge  │      │
       ┌─────────────┐                           │ Aivis TTS        │      │
       │ RDS Instance│                           │ NVIDIA T4 GPU    │      │
       │ pg17 t4g.μ  │                           │ ECR から pull    │      │
       └─────────────┘                           │ EIP / Lambda 制御│      │
                                                 └──────────────────┘      │
                                                                           │
       Secrets Manager (api / relay / db) ←──────────────────── 各サービスから参照
```

### CloudFront パス分割

| Path | Origin | Cache | Origin Request Policy | 備考 |
|------|--------|-------|----------------------|------|
| `default (/)` | S3 frontend | Managed-CachingOptimized | - | `index_rewrite` Function で `/about` → `/about/index.html` 等を補正 |
| `/api/*` | api ALB | Managed-CachingDisabled | AllViewerExceptHostHeader | NDJSON streaming のため compress=false |
| `/ws/*` | relay ALB | Managed-CachingDisabled | AllViewer | WebSocket。`Sec-WebSocket-*` 透過 |
| `/healthz` | relay ALB | Managed-CachingDisabled | AllViewer | exact match。relay の `/healthz` ハンドラ |

CloudFront → ALB の認証は `X-Stuffed-Toy-{Api,Relay}-Custom-Header` のカスタムヘッダで行い、ALB の listener rule が値を検証する（直接 ALB を叩かれても 403 を返す）。

---

## モジュール一覧

[providers/aws/module/](providers/aws/module/) に以下の独立モジュールが配置されている。

| モジュール | リソース | 主な役割 |
|-----------|----------|----------|
| [s3](providers/aws/module/s3/) | aws_s3_bucket × 7 | app_storage / system_storage / build / api_elb_log / app_cloudfront_log / athena_query_results / **frontend** |
| [waf](providers/aws/module/waf/) | aws_wafv2_web_acl + log_group | CloudFront 用 WAF（us-east-1）|
| [security-group](providers/aws/module/security-group/) | aws_security_group × 多数 | ALB / ECS / RDS / VPC Endpoint 用 SG |
| [target-group](providers/aws/module/target-group/) | aws_lb_target_group × 4 | api / relay × blue/green |
| [load-balancer](providers/aws/module/load-balancer/) | aws_lb × 2 + listener × 4 + listener_rule × 4 | api / relay の ALB |
| [vpc-endpoint](providers/aws/module/vpc-endpoint/) | aws_vpc_endpoint | Secrets Manager Interface Endpoint |
| [iam/policy](providers/aws/module/iam/policy/) | aws_iam_policy × 12 | api / relay / frontend × 各種 exec policy |
| [iam/role](providers/aws/module/iam/role/) | aws_iam_role × 12 + attachment | 上記 policy を attach した role |
| [cloudfront](providers/aws/module/cloudfront/) | aws_cloudfront_distribution + OAC × 2 + Function + response headers + logging | 配信全体 |
| [rds](providers/aws/module/rds/) | aws_db_instance + subnet/parameter group + monitoring role + secret | PostgreSQL 17 |
| [secrets-manager](providers/aws/module/secrets-manager/) | aws_secretsmanager_secret × 2 | api / relay の環境変数置き場 |
| [ecr](providers/aws/module/ecr/) | aws_ecr_repository × 5 + lifecycle_policy | bun / node / api / relay / **tts** |
| [ecs/cluster](providers/aws/module/ecs/cluster/) | aws_ecs_cluster | api / relay 共有クラスタ |
| [ecs/service](providers/aws/module/ecs/service/) | aws_ecs_service × 2 + autoscaling | api（port 3002）/ relay（port 3001）|
| [sns-topic](providers/aws/module/sns-topic/) | aws_sns_topic × 3 + policy | api / relay / frontend のビルド通知 |
| [codebuild](providers/aws/module/codebuild/) | aws_codebuild_project × 4 | api / api_migrate / relay / frontend |
| [codedeploy](providers/aws/module/codedeploy/) | aws_codedeploy_app + deployment_group × 2 | api / relay の Blue/Green |
| [codepipeline](providers/aws/module/codepipeline/) | aws_codepipeline × 3 + CodeStarNotifications | api / relay / frontend |
| [tts](providers/aws/module/tts/) | aws_instance + EBS + EIP + EIP association + SG + IAM | Aivis 音声合成エンジンが動く GPU EC2（g4dn.xlarge）|
| [night-scaling](providers/aws/module/night-scaling/) | aws_lambda × 2 + EventBridge rule × 2 + IAM | EC2 stop/start を Lambda + cron で制御（コスト削減）|

---

## CIDR 割り当て計画

このAWSアカウントでは複数プロダクトをホストするため、TGW / VPC Peering / オンプレ接続時の CIDR 重複を避ける目的で、アカウント全体の住所空間を事前に分割している。

### アカウント全体: `10.0.0.0/16`

```
10.0.0.0/16   ← アカウント全体
├── 10.0.0.0/19    stuffed-toy (プロダクトA)
│   ├── 10.0.0.0/21    dev      (2,048 IP)
│   ├── 10.0.8.0/21    staging  (2,048 IP)
│   └── 10.0.16.0/21   prod     (2,048 IP)
├── 10.0.32.0/19   プロダクトB
└── 10.0.64.0/19   プロダクトC ...
```

### 階層

| レイヤー | サイズ | IP 数 | 用途 |
|---------|--------|------|------|
| アカウント | `10.0.0.0/16` | 65,536 | このAWSアカウント全体の予約 |
| プロダクト | `/19` ごと | 8,192 | 1プロダクトに dev / staging / prod を収める |
| VPC (環境) | `/21` ごと | 2,048 | 1環境 = 1 VPC |

### 新規プロダクト追加時

1. 未使用の `/19` を上記ツリーから割り当てる
2. その `/19` 内で `dev` / `staging` / `prod` を `/21` ずつ切る
3. 本ファイルにツリーを追記する

---

## 環境別構成

### staging（[providers/aws/environments/staging/](providers/aws/environments/staging/)）

| カテゴリ | 値 |
|---------|-----|
| AWS Account | `364046406916` |
| Region | `ap-northeast-1` |
| AWS Profile | `stuffed-toy-local-deployer-staging` |
| VPC | `vpc-09005a9be2e89d16b`（既存）|
| CIDR | `10.0.8.0/21` |
| Public Subnet | 3 AZ（1a / 1c / 1d） |
| Private Subnet | 3 AZ |

#### サービス構成

| サービス | コンテナポート | TG 名 | 配置 subnet | scaling min/max | image |
|----------|--------------|-------|------------|----------------|-------|
| api | 3002 | `stuffed-toy-api-blue/green-stg` | public + Public IP | 1 / 1 | `stuffed-toy-api-staging:latest` |
| relay | 3001 | `stuffed-toy-relay-blue/green-stg` | public + Public IP | 1 / 1 | `stuffed-toy-relay-staging:latest` |

ALB は HTTP 80（main）/ 8080（sub）。CloudFront 経由のアクセスは custom header で listener rule が検証。HTTPS 化する場合は `stuffed_toy_acm_arn` に ACM ARN を設定。

#### RDS

| 項目 | 値 |
|------|-----|
| Engine / Version | `postgres` 17.4 |
| Instance Class | `db.t4g.micro`（コスト優先） |
| Storage | gp3 20GB（autoscale 〜 100GB） |
| Multi-AZ | false（staging）|
| Public Access | false |
| Encryption | AES256 |
| Backup Retention | 7 days |
| SSL 強制 | `rds.force_ssl = 1`（pending-reboot 時は Instance reboot で適用）|
| Identifier | `stuffed-toy-instance-staging` |
| DB Name / Username | `stuffed_toy` / `stuffed_toy_admin` |
| Secret パス | `/stuffed-toy/staging/db` |
| 接続 Port | 5432 |

#### Secrets Manager

| Secret 名 | 用途 | 主なキー |
|----------|------|---------|
| `/stuffed-toy/staging/db` | RDS 接続情報 | username / password / host / port / engine / dbname / sslmode |
| `/stuffed-toy/staging/api` | api アプリ環境変数 | DATABASE_URL / OPENAI_API_KEY / GEMINI_API_KEY / AIVIS_* / INTERNAL_API_KEY 他 計12 |
| `/stuffed-toy/staging/relay` | relay アプリ環境変数 | OPENAI_API_KEY / INTERNAL_API_KEY / REALTIME_WS_PORT / REALTIME_PREWARM_LANGUAGES |

`INTERNAL_API_KEY` は api と relay で **同じ値** にすること（共有認証）。

#### ECR

| リポジトリ | image_tag_mutability | Lifecycle |
|-----------|----------------------|-----------|
| `stuffed-toy-bun-staging` | MUTABLE | なし（特定バージョン保持） |
| `stuffed-toy-node-staging` | MUTABLE | なし |
| `stuffed-toy-api-staging` | MUTABLE | 直近 30 image |
| `stuffed-toy-relay-staging` | MUTABLE | 直近 30 image |
| `stuffed-toy-tts-staging` | MUTABLE | 直近 5 image（image が大きいため少なめ） |

#### CI/CD

| パイプライン | ソース | ステージ |
|-------------|-------|---------|
| `stuffed-toy-api-codepipeline-staging` | GitHub `staging` ブランチ | Source → Build → (prod: Manual_Approval) → Migrate → Deploy(CodeDeployToECS) |
| `stuffed-toy-relay-codepipeline-staging` | 同上 | Source → Build → (prod: Manual_Approval) → Deploy |
| `stuffed-toy-frontend-codepipeline-staging` | 同上 | Source → (prod: Manual_Approval) → Deploy（buildspec 内で S3 sync + CF invalidation 完結）|

CodeStar Connection（GitHub OAuth）: `arn:aws:codeconnections:us-east-1:364046406916:connection/16f8cf77-...`

TTS は CodePipeline は無く、ローカルで [`docker/tts/deploy.sh`](docker/tts/deploy.sh) を実行して ECR push + EC2 再起動する運用。

#### TTS EC2

| 項目 | 値 |
|------|-----|
| インスタンスタイプ | `g4dn.xlarge`（NVIDIA T4 GPU、4 vCPU / 16 GB）|
| AMI | Deep Learning Base OSS Nvidia Driver GPU (Ubuntu 22.04) |
| ストレージ | EBS gp3 100 GB（暗号化）|
| Public IP | EIP で固定 |
| アクセス制限 | api / relay の ECS SG からのみ port 10101 を許可 |
| SSH | 無し（SSM Session Manager で接続）|
| 起動時間 | JST 12:00（cron）|
| 停止時間 | JST 24:00（cron）|
| スケジュール有効化 | `stuffed_toy_night_scaling_enabled = false`（現状は手動 stop/start のみ）|
| 推定月額 | 約 $200（12h/日運用時。EBS / EIP 含む）|

---

## 操作

```bash
# Plan / Apply
cd providers/aws/environments/staging
sh 1_plan.sh        # plan 結果は logs/ に保存
sh 2_apply.sh

# 初回のみ（バックエンドの S3 作成）
sh 0_setup_backend.sh

# 環境を破棄したいとき
sh 99_cleanup_backend.sh
```

Terraform バージョン: **1.15.1** / AWS Provider: **6.43.0**（[providers.tf](providers/aws/environments/staging/providers.tf)）

state は S3 + S3 native lock（`use_lockfile = true`）で管理。

---

## TTS（Aivis 音声合成）の運用

### ローカルから image をビルド & デプロイ

`stuffed-toy-tts` EC2 で動かす Aivis Docker image のビルド資材は [docker/tts/](docker/tts/) に配置。

```bash
cd docker/tts
# .aivmx モデルファイルをこのディレクトリに置く（*.aivmx は git 管理外）
./deploy.sh                       # VERSION 自動採番 (例: 20260531-1800)
./deploy.sh morioki-v1            # VERSION 明示指定
./deploy.sh morioki-v1 production # ENV も指定
```

`deploy.sh` が以下を一括実行:

1. ECR login
2. `docker buildx build --platform linux/amd64`（M1/M2 Mac でも EC2 amd64 にマッチ）
3. `:${VERSION}` と `:latest` の 2 タグで ECR に push
4. EC2 が stopped なら自動 start
5. SSM 経由で `systemctl restart aivis`

詳細・トラブルシュートは [docker/tts/README.md](docker/tts/README.md) を参照。

### EC2 stop / start（コスト削減）

[night-scaling モジュール](providers/aws/module/night-scaling/) の Lambda で行う:

```bash
# 停止
aws lambda invoke --function-name stuffed-toy-night-scaling-stop-staging \
  --profile stuffed-toy-local-deployer-staging --region ap-northeast-1 out.json && cat out.json

# 起動
aws lambda invoke --function-name stuffed-toy-night-scaling-start-staging \
  --profile stuffed-toy-local-deployer-staging --region ap-northeast-1 out.json && cat out.json
```

EventBridge スケジュールを使う場合は [staging/terraform.tfvars](providers/aws/environments/staging/terraform.tfvars) で:

```hcl
stuffed_toy_night_scaling_enabled = true  # JST 12:00 起動 / JST 24:00 停止
```

→ `sh 2_apply.sh` で EventBridge が ENABLED に切り替わる。

### EC2 にログイン（デバッグ）

```bash
INSTANCE_ID=$(aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=stuffed-toy-tts-staging" \
  --profile stuffed-toy-local-deployer-staging --region ap-northeast-1 \
  --query 'Reservations[0].Instances[0].InstanceId' --output text)

aws ssm start-session --target $INSTANCE_ID \
  --profile stuffed-toy-local-deployer-staging --region ap-northeast-1
# ↓ ログイン後
sudo systemctl status aivis        # 起動状態
sudo journalctl -u aivis -n 50     # ログ
sudo nvidia-smi                     # GPU 認識
curl http://localhost:10101/speakers # API 疎通
```

### TTS のエンドポイント

VPC 内通信用の private IP は terraform output から:

```bash
cd providers/aws/environments/staging
terraform output stuffed_toy_tts_endpoint
# → http://10.0.x.x:10101
```

api / relay の Secret に `AIVIS_TTS_ENDPOINT` として登録して連携。
