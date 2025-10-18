#!/bin/bash

###
### test.sh
### TodoBar
###
### 测试运行脚本
###

set -e

echo "🧪 开始运行测试..."

# 运行单元测试
xcodebuild test \
    -scheme TodoBar \
    -destination 'platform=macOS' \
    -enableCodeCoverage YES \
    | xcpretty

echo "✅ 测试完成"

# 生成覆盖率报告（可选）
# xcrun xccov view --report --only-targets DerivedData/TodoBar/Logs/Test/*.xcresult

