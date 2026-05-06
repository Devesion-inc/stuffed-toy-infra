#!/usr/bin/env bash

# AWSプロファイル設定コマンド（事前に実行が必要）:
# aws configure --profile stuffed-toy-local-deployer-develop
# 
# 設定項目:
# AWS Access Key ID [None]: YOUR_ACCESS_KEY_ID
# AWS Secret Access Key [None]: YOUR_SECRET_ACCESS_KEY
# Default region name [None]: ap-northeast-1
# Default output format [None]: json

# 未定義変数、エラーで処理を止める
set -eu

# 格納されているディレクトリからステージ名取得 ex. develop|staging|production
CURRENT=$(cd $(dirname $0);pwd)
ENV=`echo "$CURRENT" | sed -e 's/.*\/\([^\/]*\)$/\1/'`

# AWSプロファイル名
AWS_PROFILE="stuffed-toy-local-deployer-$ENV"

# リソース名の設定
S3_BUCKET_NAME="stuffed-toy-terraform-state-$ENV"
REGION="ap-northeast-1"

echo "=========================================="
echo "Terraform Backend Setup for Environment: $ENV"
echo "=========================================="

echo "Start Directory Check"
if [ $ENV = "develop" ] || [ $ENV = "staging" ] || [ $ENV = "preview" ] || [ $ENV = "production" ] || [ $ENV = "beta" ]; then
    echo "environments/${ENV}"
    echo "Directory Check: true"
else
    echo "Error: Directory Check: false"
    exit 1
fi
echo "End Directory Check"

echo "Start AWS Profile Check"
# AWSプロファイルの存在確認
if aws configure list-profiles | grep -q "^${AWS_PROFILE}$"; then
    echo "AWS Profile '${AWS_PROFILE}' found"
    echo "AWS Profile Check: true"
else
    echo "Error: AWS Profile '${AWS_PROFILE}' not found"
    echo "Please configure AWS profile using: aws configure --profile ${AWS_PROFILE}"
    exit 1
fi
echo "End AWS Profile Check"

echo "Start AWS Credentials Test"
# AWSの認証情報テスト
if aws sts get-caller-identity --profile ${AWS_PROFILE} > /dev/null 2>&1; then
    echo "AWS credentials test: success"
    ACCOUNT_ID=$(aws sts get-caller-identity --profile ${AWS_PROFILE} --query Account --output text)
    echo "AWS Account ID: ${ACCOUNT_ID}"
else
    echo "Error: AWS credentials test failed"
    echo "Please check your AWS credentials for profile: ${AWS_PROFILE}"
    exit 1
fi
echo "End AWS Credentials Test"

echo "Start S3 Bucket Creation"
# S3バケットの存在確認
if aws s3api head-bucket --bucket ${S3_BUCKET_NAME} --profile ${AWS_PROFILE} 2>/dev/null; then
    echo "S3 bucket '${S3_BUCKET_NAME}' already exists"
else
    echo "Creating S3 bucket: ${S3_BUCKET_NAME}"
    
    # S3バケット作成
    if aws s3api create-bucket \
        --bucket ${S3_BUCKET_NAME} \
        --region ${REGION} \
        --create-bucket-configuration LocationConstraint=${REGION} \
        --profile ${AWS_PROFILE}; then
        echo "S3 bucket created successfully"
    else
        echo "Error: Failed to create S3 bucket"
        exit 1
    fi
    
    # バケットバージョニング有効化
    echo "Enabling versioning on S3 bucket"
    aws s3api put-bucket-versioning \
        --bucket ${S3_BUCKET_NAME} \
        --versioning-configuration Status=Enabled \
        --profile ${AWS_PROFILE}
    
    # パブリックアクセスブロック設定
    echo "Setting public access block on S3 bucket"
    aws s3api put-public-access-block \
        --bucket ${S3_BUCKET_NAME} \
        --public-access-block-configuration \
        "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true" \
        --profile ${AWS_PROFILE}
    
    # サーバーサイド暗号化設定
    echo "Setting server-side encryption on S3 bucket"
    aws s3api put-bucket-encryption \
        --bucket ${S3_BUCKET_NAME} \
        --server-side-encryption-configuration \
        '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}' \
        --profile ${AWS_PROFILE}
fi
echo "End S3 Bucket Creation"

echo "=========================================="
echo "Backend Setup Completed Successfully!"
echo "=========================================="
echo ""
echo "Resources created:"
echo "- S3 Bucket: ${S3_BUCKET_NAME}"
echo "- Region: ${REGION}"
echo "- AWS Profile: ${AWS_PROFILE}"
echo ""
echo "State locking is handled natively by S3 (use_lockfile = true)."
echo "DynamoDB table is no longer required (Terraform >= 1.10)."
echo ""
echo "You can now configure your Terraform backend with these resources:"
echo ""
echo "terraform {"
echo "  backend \"s3\" {"
echo "    bucket       = \"${S3_BUCKET_NAME}\""
echo "    key          = \"terraform.tfstate\""
echo "    region       = \"${REGION}\""
echo "    profile      = \"${AWS_PROFILE}\""
echo "    use_lockfile = true"
echo "  }"
echo "}"
echo ""
