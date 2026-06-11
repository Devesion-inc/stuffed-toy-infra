#!/usr/bin/env bash
# ECR login → build → push → EC2 再起動 を一発で実行
#
# 使い方:
#   cd docker/tts
#   # .aivmx ファイルをこのディレクトリに配置
#
#   ./deploy.sh                          # VERSION=自動採番(YYYYMMDD-HHmm), ENV=staging
#   ./deploy.sh morioki-v1               # VERSION=morioki-v1, ENV=staging
#   ./deploy.sh morioki-v1 production    # 環境追加時の指定方法
#   VERSION=morioki-v1 ./deploy.sh       # 環境変数経由
#
# Push されるタグ:
#   - :${VERSION}（履歴管理用）
#   - :latest（EC2 が常に参照する移動タグ）

set -euo pipefail

# 引数 > 環境変数 > デフォルト
VERSION="${1:-${VERSION:-$(date +%Y%m%d-%H%M)}}"
ENV="${2:-${ENV:-staging}}"

ACCOUNT="364046406916"
REGION="ap-northeast-1"
PROFILE="stuffed-toy-local-deployer-${ENV}"
REGISTRY="${ACCOUNT}.dkr.ecr.${REGION}.amazonaws.com"
REPO="stuffed-toy-tts-${ENV}"

cd "$(dirname "$0")"

echo "🏷  VERSION: ${VERSION}"
echo "🌍 ENV:     ${ENV}"
echo ""

# .aivmx の存在チェック
shopt -s nullglob
AIVMX_FILES=(*.aivmx)
if [ ${#AIVMX_FILES[@]} -eq 0 ]; then
  echo "❌ ${PWD} に .aivmx ファイルがありません。Aivis Hub からダウンロードして配置してください。"
  exit 1
fi
echo "📦 焼き込むモデル: ${AIVMX_FILES[*]}"

# 1. ECR login
echo "🔐 ECR にログイン..."
aws ecr get-login-password --region "$REGION" --profile "$PROFILE" | \
  docker login --username AWS --password-stdin "$REGISTRY"

# 2. Build (linux/amd64 強制：EC2 g4dn は x86_64)
#    VERSION と latest の両方のタグを付与
echo "🏗  Docker image をビルド..."
docker buildx build --platform linux/amd64 \
  -t "${REGISTRY}/${REPO}:${VERSION}" \
  -t "${REGISTRY}/${REPO}:latest" \
  --load \
  .

# 3. Push（VERSION と latest の両方）
echo "🚀 ECR に push (tag: ${VERSION})..."
docker push "${REGISTRY}/${REPO}:${VERSION}"

echo "🚀 ECR に push (tag: latest)..."
docker push "${REGISTRY}/${REPO}:latest"

echo ""
echo "✅ Push 完了"
echo "   - ${REGISTRY}/${REPO}:${VERSION}"
echo "   - ${REGISTRY}/${REPO}:latest"
echo ""

# 4. EC2 で aivis service を再起動
echo "🔍 EC2 インスタンス ID を取得..."
INSTANCE_ID=$(aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=stuffed-toy-tts-${ENV}" \
            "Name=instance-state-name,Values=running,stopped" \
  --profile "$PROFILE" --region "$REGION" \
  --query 'Reservations[0].Instances[0].InstanceId' --output text)

if [ "$INSTANCE_ID" == "None" ] || [ -z "$INSTANCE_ID" ]; then
  echo ""
  echo "ℹ️  EC2 インスタンスが見つかりませんでした。"
  echo "    image の ECR push は完了しているので、EC2 を作成（terraform apply）すれば"
  echo "    起動時に systemd が ECR から自動 pull します。"
  echo ""
  echo "✅ Phase 2 (image push) 完了。次は staging/main.tf の tts / night-scaling のコメントを外して apply してください。"
  exit 0
fi

# EC2 が stopped なら start
STATE=$(aws ec2 describe-instances --instance-ids "$INSTANCE_ID" \
  --profile "$PROFILE" --region "$REGION" \
  --query 'Reservations[0].Instances[0].State.Name' --output text)

if [ "$STATE" != "running" ]; then
  echo "▶️  EC2 が ${STATE} なので start..."
  aws ec2 start-instances --instance-ids "$INSTANCE_ID" \
    --profile "$PROFILE" --region "$REGION" >/dev/null
  echo "⏳ running になるまで待機..."
  aws ec2 wait instance-running --instance-ids "$INSTANCE_ID" \
    --profile "$PROFILE" --region "$REGION"
fi

# SSM agent が ready になるまで少し待つ
echo "⏳ SSM Agent 起動を待機 (10秒)..."
sleep 10

# 5. systemd service を再起動
echo "🔄 aivis service を再起動..."
CMD_ID=$(aws ssm send-command \
  --instance-ids "$INSTANCE_ID" \
  --document-name "AWS-RunShellScript" \
  --parameters 'commands=["systemctl restart aivis","sleep 5","systemctl status aivis --no-pager"]' \
  --profile "$PROFILE" --region "$REGION" \
  --query 'Command.CommandId' --output text)

echo "⏳ コマンド実行待ち..."
sleep 8

aws ssm get-command-invocation \
  --command-id "$CMD_ID" --instance-id "$INSTANCE_ID" \
  --profile "$PROFILE" --region "$REGION" \
  --query '{Status:Status,Output:StandardOutputContent}' --output json

echo ""
echo "✅ デプロイ完了"
echo "📡 TTS エンドポイント: http://<PRIVATE_IP>:10101/speakers でスピーカー一覧を確認可能"
echo "   private IP は terraform output stuffed_toy_tts_endpoint で取得"
