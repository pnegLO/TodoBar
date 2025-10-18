#!/bin/bash

###
### lint.sh
### TodoBar
###
### SwiftLint 检查脚本
###

set -e

# 检查 swiftlint 是否安装
if ! command -v swiftlint &> /dev/null; then
    echo "❌ SwiftLint 未安装"
    echo "请运行: brew install swiftlint"
    exit 1
fi

echo "🔍 开始 SwiftLint 检查..."

# 运行 swiftlint
swiftlint lint --strict

echo "✅ SwiftLint 检查完成"

