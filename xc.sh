#!/bin/bash

if [ -z "$1" ]; then
  echo "Ошибка: Не указана схема для сборки."
  exit 1
fi

SCHEME="$1"

echo "📦 Сборка проекта для iOS устройств (arm64)"
xcodebuild build \
  -project "EasyCode.xcodeproj" \
  -scheme "$SCHEME" \
  -sdk iphoneos \
  -configuration Release \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES || exit 1

echo "📦 Сборка проекта для iOS симуляторов (x86_64, arm64)"
xcodebuild build \
  -project "EasyCode.xcodeproj" \
  -scheme "$SCHEME" \
  -sdk iphonesimulator \
  -configuration Release \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES || exit 1

echo "📱 Архивация для iOS устройств"
xcodebuild archive \
  -project "EasyCode.xcodeproj" \
  -scheme "$SCHEME" \
  -archivePath "./build/ios_devices.xcarchive" \
  -sdk iphoneos \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES || exit 1

echo "🖥 Архивация для iOS симулятора"
xcodebuild archive \
  -project "EasyCode.xcodeproj" \
  -scheme "$SCHEME" \
  -archivePath "./build/ios_simulators.xcarchive" \
  -sdk iphonesimulator \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  EXCLUDED_ARCHS=arm64 || exit 1

echo "❇ Создание XCFramework"
xcodebuild -create-xcframework \
  -framework "./build/ios_devices.xcarchive/Products/Library/Frameworks/EasyCode.framework" \
  -framework "./build/ios_simulators.xcarchive/Products/Library/Frameworks/EasyCode.framework" \
  -output "EasyCode.xcframework" || exit 1
  echo "✅ XCFramework успешно создан!"
