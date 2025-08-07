#!/bin/bash

# Check if commit message is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <commit_message>"
    echo "Example: $0 'Fix iOS 16 warnings and improve carrier detection'"
    exit 1
fi

COMMIT_MESSAGE="$1"

git add .
git commit -m "$COMMIT_MESSAGE"
git push origin main
# git tag -d v1.0.4
git tag v1.0.4
git push origin v1.0.4 --force
pod cache clean --all
pod spec lint InhouseTrackingSDK.podspec --use-libraries