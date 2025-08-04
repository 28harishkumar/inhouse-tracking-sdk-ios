#!/bin/bash

# InhouseTrackingSDK Podspec Validation Script
echo "🔍 Validating InhouseTrackingSDK.podspec..."

# Check if podspec exists
if [ ! -f "InhouseTrackingSDK.podspec" ]; then
    echo "❌ Error: InhouseTrackingSDK.podspec not found!"
    exit 1
fi

# Check if InhouseTrackingSDK directory exists
if [ ! -d "InhouseTrackingSDK" ]; then
    echo "❌ Error: InhouseTrackingSDK directory not found!"
    exit 1
fi

# Check if all Swift files exist
echo "📁 Checking Swift files..."
SWIFT_FILES=(
    "InhouseTrackingSDK/InhouseTrackingSDK.swift"
    "InhouseTrackingSDK/Models.swift"
    "InhouseTrackingSDK/StorageManager.swift"
    "InhouseTrackingSDK/NetworkClient.swift"
    "InhouseTrackingSDK/EventTracker.swift"
    "InhouseTrackingSDK/ShortLinkDetector.swift"
    "InhouseTrackingSDK/DeepLinkHandler.swift"
    "InhouseTrackingSDK/InstallReferrerManager.swift"
)

for file in "${SWIFT_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo "❌ Error: $file not found!"
        exit 1
    else
        echo "✅ $file exists"
    fi
done

# Check if LICENSE exists
if [ ! -f "LICENSE" ]; then
    echo "❌ Error: LICENSE file not found!"
    exit 1
else
    echo "✅ LICENSE exists"
fi

# Validate podspec
echo "🔧 Validating podspec..."
pod spec lint InhouseTrackingSDK.podspec --allow-warnings

if [ $? -eq 0 ]; then
    echo "✅ Podspec validation successful!"
    echo ""
    echo "🚀 Ready to push to CocoaPods!"
    echo "Run: pod trunk push InhouseTrackingSDK.podspec"
else
    echo "❌ Podspec validation failed!"
    echo "Run: pod spec lint InhouseTrackingSDK.podspec --verbose"
    exit 1
fi 