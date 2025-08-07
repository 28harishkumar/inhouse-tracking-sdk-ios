git add .
git commit -m "working on fixing ios 16 warnings"
git push origin main
git tag -d v1.0.3
git tag v1.0.3
git push origin v1.0.3 --force
pod cache clean --all
pod spec lint InhouseTrackingSDK.podspec --use-libraries