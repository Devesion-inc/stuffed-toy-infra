# stuffed-toy TTS（Aivis 音声合成エンジン）

[stuffed-toy-tts EC2](../../providers/aws/module/tts/) で動かす Aivis Docker イメージのビルド資材。

## ディレクトリ構成

```
docker/tts/
├── Dockerfile     # Aivis ベース image に *.aivmx を COPY
├── deploy.sh      # ECR login → build → push → EC2 再起動を一発実行
├── README.md      # このファイル
└── .gitignore     # *.aivmx を git 管理外に
```

`.aivmx` モデルファイル本体は **git にはコミットしません**（バイナリ大）。ローカルにダウンロードしてこのディレクトリに置いてください。

## 前提

- Docker Desktop が起動している
- AWS CLI に `stuffed-toy-local-deployer-staging` プロファイルが設定済み
- Aivis Hub から `.aivmx` モデルファイルをダウンロード済み
- `terraform apply` 完了済み（ECR リポジトリと EC2 が存在）

## 使い方

### 初回 / モデル更新時

1. **`.aivmx` ファイルをこのディレクトリに配置**

   ```bash
   cp ~/Downloads/morioki.aivmx ./
   # 複数モデル使うなら複数置く（Dockerfile は *.aivmx を全部 COPY する）
   ```

2. **deploy.sh を実行**（staging）

   ```bash
   cd docker/tts
   ./deploy.sh                      # VERSION 自動採番 (例: 20260531-1759)
   ./deploy.sh morioki-v1           # VERSION 指定
   ./deploy.sh morioki-v1 staging   # ENV も指定（位置引数の 2 番目）
   VERSION=morioki-v1 ./deploy.sh   # 環境変数経由でも OK
   ```

   内部で以下が走ります:
   - ECR login
   - `docker buildx build --platform linux/amd64`（M1/M2 Mac でも EC2 amd64 に合わせて build）
   - **`:${VERSION}` と `:latest` の 2 タグを push**
   - EC2 が stopped なら自動起動
   - SSM 経由で `systemctl restart aivis`

   M1/M2 Mac で初回ビルドは数分〜10分（QEMU 経由で遅め）、2 回目以降はキャッシュで高速。

   ### バージョン管理について

   - **`:VERSION`**（例 `:morioki-v1`, `:20260531-1759`）→ ECR に履歴として残る。lifecycle policy で **直近 5 タグだけ保持**
   - **`:latest`** → 常に最新を指す移動タグ。EC2 の systemd は `:latest` を pull
   - **過去バージョンに戻したい場合**: EC2 にログインして `docker pull <REGISTRY>/<REPO>:morioki-v1` してから systemd 設定変更

3. **動作確認**

   ```bash
   # private IP を確認
   cd ../../providers/aws/environments/staging
   terraform output stuffed_toy_tts_endpoint
   # → http://10.0.x.x:10101

   # ECS タスクから疎通テスト（api コンテナ内で）
   curl http://10.0.x.x:10101/speakers
   ```

## 引数

`deploy.sh` の引数:

```bash
./deploy.sh [VERSION] [ENV]
```

| 位置 | 名前 | デフォルト |
|------|------|-----------|
| 1 | VERSION | 自動採番（`YYYYMMDD-HHmm`）|
| 2 | ENV | `staging` |

両方とも環境変数 `VERSION` / `ENV` でも指定可能（引数優先）。

## コスト節約: 使わない時は停止

開発で TTS を使わない時間帯は EC2 を停止できます（EBS と EIP 分の数ドル/月以外は課金されません）:

```bash
# 停止
aws lambda invoke --function-name stuffed-toy-night-scaling-stop-staging \
  --profile stuffed-toy-local-deployer-staging --region ap-northeast-1 out.json && cat out.json

# 起動
aws lambda invoke --function-name stuffed-toy-night-scaling-start-staging \
  --profile stuffed-toy-local-deployer-staging --region ap-northeast-1 out.json && cat out.json
```

夜間自動停止が必要なら [staging/terraform.tfvars](../../providers/aws/environments/staging/terraform.tfvars) で:

```hcl
stuffed_toy_night_scaling_enabled = true  # JST 22:00 停止 / 09:00 起動
```

## EC2 に SSH せずにログイン（デバッグ用）

```bash
INSTANCE_ID=$(aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=stuffed-toy-tts-staging" \
  --profile stuffed-toy-local-deployer-staging --region ap-northeast-1 \
  --query 'Reservations[0].Instances[0].InstanceId' --output text)

aws ssm start-session --target $INSTANCE_ID \
  --profile stuffed-toy-local-deployer-staging --region ap-northeast-1

# ↓ ログイン後のシェルで
sudo systemctl status aivis
sudo journalctl -u aivis -n 100
sudo docker ps
nvidia-smi
curl http://localhost:10101/speakers
exit
```

## トラブルシュート

| 症状 | 対処 |
|------|------|
| `denied: ...` (push 時) | ECR login の 12 時間期限切れ。`deploy.sh` 再実行で再 login |
| build が遅い | M1/M2 で amd64 build = QEMU 経由。仕様 |
| `systemctl status aivis` が `failed` | `sudo journalctl -u aivis -n 100` でログ確認。多くは image pull 失敗 → ECR に image があるか `aws ecr list-images` で確認 |
| `/speakers` が空配列 | `.aivmx` が Dockerfile で正しく COPY されているか確認 |
| `nvidia-smi` not found | Deep Learning AMI 起動失敗。terraform で再作成 |
