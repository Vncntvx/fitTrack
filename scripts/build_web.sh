#!/bin/bash

# Web 构建脚本
# 用于构建 Flutter Web 并同步到 LAN 后台资源目录

set -e

echo "Building Flutter Web..."

# 构建 Web
flutter build web --release

# 同步到 Flutter 资产目录，供 LAN 服务和 Android 打包复用
mkdir -p assets/webapp
rsync -a --delete build/web/ assets/webapp/

echo "Web build completed and synced to assets/webapp/"
echo "Run 'flutter build apk' to include the Flutter Web LAN UI in the Android app"
