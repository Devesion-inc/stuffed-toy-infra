#!/usr/bin/env bash

# 未定義変数、エラーで処理を止める
set -eu

# 格納されているディレクトリからステージ名取得 ex. develop|staging|production
CURRENT=$(cd $(dirname $0);pwd)
ENV=`echo "$CURRENT" | sed -e 's/.*\/\([^\/]*\)$/\1/'`

echo "Start Directry Check"
if [ $ENV = "develop" ] || [ $ENV = "staging" ] || [ $ENV = "preview" ] || [ $ENV = "production" ] || [ $ENV = "beta" ]; then
    echo "environments/${ENV}"
    echo "Directry Check: true"
else
    echo "Error: Directry Check: false"
    exit 1
fi
echo "End Directry Check"

echo "Start terraform init"
terraform init -var=aws_profile="stuffed-toy-local-deployer-$ENV"
echo "End terraform init"

echo "Start terraform apply"
terraform apply -var=aws_profile="stuffed-toy-local-deployer-$ENV" -no-color | tee -a ./logs/`date "+%Y%m%d_%H%M%S"`_apply.log
echo "End terraform apply"