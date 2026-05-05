#!/usr/bin/env bash

# Terraform Backend Cleanup Script for Staging Environment
# このスクリプトは0_setup_backend.shで作成されたリソースを削除します
# 
# 削除対象:
# - S3バケット内のオブジェクト（全バージョン含む）
# - S3バケット
# - DynamoDBテーブル

# 未定義変数、エラーで処理を止める
set -eu

# 格納されているディレクトリからステージ名取得 ex. develop|staging|production
CURRENT=$(cd $(dirname $0);pwd)
ENV=`echo "$CURRENT" | sed -e 's/.*\/\([^\/]*\)$/\1/'`

# AWSプロファイル名
AWS_PROFILE="stuffed-toy-local-deployer-$ENV"

# リソース名の設定
S3_BUCKET_NAME="stuffed-toy-terraform-state-$ENV"
DYNAMODB_TABLE_NAME="stuffed-toy-terraform-locks-$ENV"
REGION="ap-northeast-1"

echo "=========================================="
echo "Terraform Backend Cleanup for Environment: $ENV"
echo "=========================================="
echo ""
echo "⚠️  WARNING: This will DELETE the following resources:"
echo "   - S3 Bucket: ${S3_BUCKET_NAME} (and ALL contents)"
echo "   - DynamoDB Table: ${DYNAMODB_TABLE_NAME}"
echo "   - Region: ${REGION}"
echo "   - AWS Profile: ${AWS_PROFILE}"
echo ""

# 1回目の確認
echo "=========================================="
echo "FIRST CONFIRMATION"
echo "=========================================="
read -p "Are you ABSOLUTELY SURE you want to delete these resources? (type 'yes' to continue): " FIRST_CONFIRM

if [ "$FIRST_CONFIRM" != "yes" ]; then
    echo "Operation cancelled by user."
    exit 0
fi

echo ""
echo "=========================================="
echo "SECOND CONFIRMATION"
echo "=========================================="
echo "⚠️  FINAL WARNING: This action is IRREVERSIBLE!"
echo "   All Terraform state files will be permanently deleted."
echo "   This may cause issues with existing infrastructure."
echo ""
read -p "Type the environment name '${ENV}' to confirm deletion: " SECOND_CONFIRM

if [ "$SECOND_CONFIRM" != "$ENV" ]; then
    echo "Environment name mismatch. Operation cancelled."
    exit 0
fi

echo ""
echo "Starting cleanup process..."

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

echo "Start jq Command Check"
# jqコマンドの存在確認
if ! command -v jq &> /dev/null; then
    echo "Error: jq command not found"
    echo "Please install jq: brew install jq (macOS) or apt-get install jq (Linux)"
    exit 1
fi
echo "jq command found"
echo "End jq Command Check"

echo "Start S3 Bucket Cleanup"
# S3バケットの存在確認（head-bucketは成功時に終了コード0を返す）
if aws s3api head-bucket --bucket ${S3_BUCKET_NAME} --profile ${AWS_PROFILE} 2>/dev/null; then
    echo "S3 bucket '${S3_BUCKET_NAME}' found"
    
    echo "Listing bucket contents..."
    OBJECT_COUNT=$(aws s3api list-object-versions --bucket ${S3_BUCKET_NAME} --profile ${AWS_PROFILE} --query 'length(Versions[])' --output text 2>/dev/null || echo "0")
    DELETE_MARKER_COUNT=$(aws s3api list-object-versions --bucket ${S3_BUCKET_NAME} --profile ${AWS_PROFILE} --query 'length(DeleteMarkers[])' --output text 2>/dev/null || echo "0")
    
    echo "Found ${OBJECT_COUNT} object versions and ${DELETE_MARKER_COUNT} delete markers"
    
    if [ "$OBJECT_COUNT" != "0" ] || [ "$DELETE_MARKER_COUNT" != "0" ]; then
        echo "Deleting all object versions and delete markers..."
        
        DELETE_ERRORS=0
        
        # オブジェクトバージョンを削除（evalを使わず、配列として処理）
        if [ "$OBJECT_COUNT" != "0" ]; then
            OBJECT_LIST=$(aws s3api list-object-versions --bucket ${S3_BUCKET_NAME} --profile ${AWS_PROFILE} --query 'Versions[].{Key:Key,VersionId:VersionId}' --output json 2>/dev/null)
            if [ $? -ne 0 ] || [ -z "$OBJECT_LIST" ]; then
                echo "Error: Failed to list object versions"
                DELETE_ERRORS=$((DELETE_ERRORS + 1))
            else
                # 一時ファイルを使用してエラーをカウント（サブシェルの問題を回避）
                TEMP_ERROR_FILE=$(mktemp)
                echo "$OBJECT_LIST" | jq -r '.[] | "\(.Key)|\(.VersionId)"' 2>/dev/null | \
                while IFS='|' read -r key version_id; do
                    if [ -z "$key" ] || [ -z "$version_id" ]; then
                        continue
                    fi
                    if aws s3api delete-object --bucket ${S3_BUCKET_NAME} --key "${key}" --version-id "${version_id}" --profile ${AWS_PROFILE} > /dev/null 2>&1; then
                        echo "Deleted object version: ${key} (${version_id})"
                    else
                        echo "Warning: Failed to delete object version: ${key} (${version_id})"
                        echo "1" >> "$TEMP_ERROR_FILE"
                    fi
                done
                if [ -f "$TEMP_ERROR_FILE" ]; then
                    ERROR_COUNT=$(wc -l < "$TEMP_ERROR_FILE" | tr -d ' ')
                    DELETE_ERRORS=$((DELETE_ERRORS + ERROR_COUNT))
                    rm -f "$TEMP_ERROR_FILE"
                fi
            fi
        fi
        
        # 削除マーカーを削除（evalを使わず、配列として処理）
        if [ "$DELETE_MARKER_COUNT" != "0" ]; then
            DELETE_MARKER_LIST=$(aws s3api list-object-versions --bucket ${S3_BUCKET_NAME} --profile ${AWS_PROFILE} --query 'DeleteMarkers[].{Key:Key,VersionId:VersionId}' --output json 2>/dev/null)
            if [ $? -ne 0 ] || [ -z "$DELETE_MARKER_LIST" ]; then
                echo "Error: Failed to list delete markers"
                DELETE_ERRORS=$((DELETE_ERRORS + 1))
            else
                # 一時ファイルを使用してエラーをカウント（サブシェルの問題を回避）
                TEMP_ERROR_FILE=$(mktemp)
                echo "$DELETE_MARKER_LIST" | jq -r '.[] | "\(.Key)|\(.VersionId)"' 2>/dev/null | \
                while IFS='|' read -r key version_id; do
                    if [ -z "$key" ] || [ -z "$version_id" ]; then
                        continue
                    fi
                    if aws s3api delete-object --bucket ${S3_BUCKET_NAME} --key "${key}" --version-id "${version_id}" --profile ${AWS_PROFILE} > /dev/null 2>&1; then
                        echo "Deleted delete marker: ${key} (${version_id})"
                    else
                        echo "Warning: Failed to delete delete marker: ${key} (${version_id})"
                        echo "1" >> "$TEMP_ERROR_FILE"
                    fi
                done
                if [ -f "$TEMP_ERROR_FILE" ]; then
                    ERROR_COUNT=$(wc -l < "$TEMP_ERROR_FILE" | tr -d ' ')
                    DELETE_ERRORS=$((DELETE_ERRORS + ERROR_COUNT))
                    rm -f "$TEMP_ERROR_FILE"
                fi
            fi
        fi
        
        if [ $DELETE_ERRORS -eq 0 ]; then
            echo "All bucket contents deleted successfully"
        else
            echo "Warning: Some objects failed to delete (${DELETE_ERRORS} errors)"
            echo "The bucket may not be completely empty. Please check manually."
        fi
    else
        echo "Bucket is already empty"
    fi
    
    # S3バケット削除
    echo "Deleting S3 bucket: ${S3_BUCKET_NAME}"
    if aws s3api delete-bucket --bucket ${S3_BUCKET_NAME} --profile ${AWS_PROFILE}; then
        echo "S3 bucket deleted successfully"
    else
        echo "Error: Failed to delete S3 bucket"
        echo "Please check if the bucket is completely empty and try again"
        exit 1
    fi
else
    echo "S3 bucket '${S3_BUCKET_NAME}' not found (already deleted or never existed)"
fi
echo "End S3 Bucket Cleanup"

echo "Start DynamoDB Table Cleanup"
# DynamoDBテーブルの存在確認
if aws dynamodb describe-table --table-name ${DYNAMODB_TABLE_NAME} --profile ${AWS_PROFILE} --region ${REGION} > /dev/null 2>&1; then
    echo "DynamoDB table '${DYNAMODB_TABLE_NAME}' found"
    
    # DynamoDBテーブル削除
    echo "Deleting DynamoDB table: ${DYNAMODB_TABLE_NAME}"
    if aws dynamodb delete-table --table-name ${DYNAMODB_TABLE_NAME} --region ${REGION} --profile ${AWS_PROFILE} > /dev/null 2>&1; then
        echo "DynamoDB table deletion initiated successfully"
        
        # テーブルが完全に削除されるまで待機（タイムアウト付き）
        echo "Waiting for DynamoDB table to be completely deleted..."
        
        # 最大30回（約3分）待機
        for i in {1..30}; do
            if aws dynamodb describe-table --table-name ${DYNAMODB_TABLE_NAME} --region ${REGION} --profile ${AWS_PROFILE} > /dev/null 2>&1; then
                TABLE_STATUS=$(aws dynamodb describe-table \
                    --table-name ${DYNAMODB_TABLE_NAME} \
                    --region ${REGION} \
                    --profile ${AWS_PROFILE} \
                    --query 'Table.TableStatus' \
                    --output text 2>/dev/null || echo "DELETED")
                
                if [ "$TABLE_STATUS" = "DELETING" ]; then
                    echo "Table status: DELETING (attempt $i/30)"
                    sleep 6
                else
                    echo "Unexpected table status: $TABLE_STATUS"
                    sleep 6
                fi
            else
                echo "DynamoDB table has been completely deleted"
                break
            fi
            
            if [ $i -eq 30 ]; then
                echo "Warning: Table deletion may still be in progress"
                echo "You can check the status manually with: aws dynamodb describe-table --table-name ${DYNAMODB_TABLE_NAME} --region ${REGION} --profile ${AWS_PROFILE}"
            fi
        done
    else
        echo "Error: Failed to delete DynamoDB table"
        exit 1
    fi
else
    echo "DynamoDB table '${DYNAMODB_TABLE_NAME}' not found (already deleted or never existed)"
fi
echo "End DynamoDB Table Cleanup"

echo "=========================================="
echo "Backend Cleanup Completed Successfully!"
echo "=========================================="
echo ""
echo "Resources deleted:"
echo "- S3 Bucket: ${S3_BUCKET_NAME} (including all contents)"
echo "- DynamoDB Table: ${DYNAMODB_TABLE_NAME}"
echo "- Region: ${REGION}"
echo "- AWS Profile: ${AWS_PROFILE} (profile still exists)"
echo ""
echo "⚠️  Note: The AWS profile '${AWS_PROFILE}' still exists."
echo "   If you want to remove it, run: aws configure delete --profile ${AWS_PROFILE}"
echo ""
echo "✅ Cleanup completed. The Terraform backend resources have been removed."
echo ""
