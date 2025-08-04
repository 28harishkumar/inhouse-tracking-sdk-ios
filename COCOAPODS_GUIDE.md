# CocoaPods Publishing Guide for InhouseTrackingSDK

This guide will walk you through the process of publishing the InhouseTrackingSDK to CocoaPods.

## Prerequisites

1. **CocoaPods Account**: You need a CocoaPods account
2. **GitHub Repository**: The SDK should be in a public GitHub repository
3. **Git Tags**: Version tags should be created for releases
4. **CocoaPods CLI**: Install CocoaPods if not already installed

## Step 1: Install CocoaPods (if not installed)

```bash
sudo gem install cocoapods
```

## Step 2: Setup CocoaPods Account

### Register with CocoaPods

```bash
pod trunk register your-email@example.com "Your Name"
```

### Verify your email

Check your email and click the verification link.

### Verify your account

```bash
pod trunk me
```

## Step 3: Prepare Your Repository

### 1. Create GitHub Repository

Create a public GitHub repository named `inhouse-tracking-sdk-ios` with the following structure:

```
inhouse-tracking-sdk-ios/
├── InhouseTrackingSDK/
│   ├── InhouseTrackingSDK.swift
│   ├── Models.swift
│   ├── StorageManager.swift
│   ├── NetworkClient.swift
│   ├── EventTracker.swift
│   ├── ShortLinkDetector.swift
│   ├── DeepLinkHandler.swift
│   └── InstallReferrerManager.swift
├── InhouseTrackingSDK.podspec
├── LICENSE
└── README.md
```

### 2. Push to GitHub

```bash
git init
git add .
git commit -m "Initial commit: InhouseTrackingSDK iOS SDK"
git branch -M main
git remote add origin https://github.com/28harishkumar/inhouse-tracking-sdk-ios.git
git push -u origin main
```

## Step 4: Create Version Tags

### Create and push version tags

```bash
# Create a tag for version 1.0.0
git tag -a v1.0.0 -m "Version 1.0.0"
git push origin v1.0.0

# For future versions
git tag -a v1.0.1 -m "Version 1.0.1"
git push origin v1.0.1
```

## Step 5: Validate Podspec

### Validate the podspec locally

```bash
cd ios-sdk
pod spec lint InhouseTrackingSDK.podspec
```

### Validate with warnings (if needed)

```bash
pod spec lint InhouseTrackingSDK.podspec --allow-warnings
```

### Validate with verbose output

```bash
pod spec lint InhouseTrackingSDK.podspec --verbose
```

## Step 6: Push to CocoaPods

### Push the podspec to CocoaPods

```bash
pod trunk push InhouseTrackingSDK.podspec
```

### If you get warnings, push with allow-warnings

```bash
pod trunk push InhouseTrackingSDK.podspec --allow-warnings
```

## Step 7: Verify Publication

### Check if your pod is published

```bash
pod search InhouseTrackingSDK
```

### Or check on CocoaPods website

Visit: https://cocoapods.org/?q=InhouseTrackingSDK

## Step 8: Update Podspec for New Versions

When you want to release a new version:

### 1. Update version in podspec

Edit `InhouseTrackingSDK.podspec`:

```ruby
spec.version = "1.0.1"  # Change version number
```

### 2. Create new git tag

```bash
git add .
git commit -m "Update version to 1.0.1"
git tag -a v1.0.1 -m "Version 1.0.1"
git push origin main
git push origin v1.0.1
```

### 3. Push new version to CocoaPods

```bash
pod trunk push InhouseTrackingSDK.podspec
```

## Troubleshooting

### Common Issues and Solutions

#### 1. "Pod not found" error

```bash
# Make sure you're in the correct directory
cd ios-sdk
pod spec lint InhouseTrackingSDK.podspec
```

#### 2. "No such file or directory" error

```bash
# Check if all files exist
ls -la InhouseTrackingSDK/
```

#### 3. "Git tag not found" error

```bash
# Make sure the tag exists and is pushed
git tag -l
git push origin --tags
```

#### 4. "Pod already exists" error

```bash
# Check if pod already exists
pod search InhouseTrackingSDK

# If it exists, you need to update the version number
```

#### 5. "Validation failed" error

```bash
# Check the validation errors
pod spec lint InhouseTrackingSDK.podspec --verbose

# Common fixes:
# - Update source_files path
# - Fix framework dependencies
# - Update platform version
```

## Podspec Configuration Details

### Basic Configuration

```ruby
Pod::Spec.new do |spec|
  spec.name         = "InhouseTrackingSDK"
  spec.version      = "1.0.0"
  spec.summary      = "A comprehensive iOS SDK for tracking..."
  spec.description  = "Detailed description..."
  spec.homepage     = "https://github.com/tryinhouse/tracking-sdk-ios"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "TryInHouse" => "support@tryinhouse.com" }
  spec.platform     = :ios, "13.0"
  spec.source       = { :git => "https://github.com/tryinhouse/tracking-sdk-ios.git", :tag => "#{spec.version}" }
  spec.source_files = "InhouseTrackingSDK/*.swift"
  spec.swift_version = "5.0"
  spec.requires_arc = true
end
```

### Advanced Configuration Options

#### Add Dependencies

```ruby
spec.dependency "Alamofire", "~> 5.0"
spec.dependency "SwiftyJSON", "~> 5.0"
```

#### Add System Frameworks

```ruby
spec.frameworks = "Foundation", "UIKit", "SystemConfiguration"
```

#### Add Weak Frameworks

```ruby
spec.weak_frameworks = "AdSupport", "iAd"
```

#### Add Libraries

```ruby
spec.libraries = "sqlite3", "z"
```

#### Add Resources

```ruby
spec.resource_bundles = {
  'InhouseTrackingSDK' => ['InhouseTrackingSDK/Resources/*']
}
```

#### Add Subspecs

```ruby
spec.subspec "Core" do |ss|
  ss.source_files = "InhouseTrackingSDK/Core/*.swift"
end

spec.subspec "Analytics" do |ss|
  ss.source_files = "InhouseTrackingSDK/Analytics/*.swift"
  ss.dependency "InhouseTrackingSDK/Core"
end
```

## Usage After Publication

Once published, users can install your SDK using:

### Podfile

```ruby
platform :ios, '13.0'

target 'YourApp' do
  use_frameworks!

  pod 'InhouseTrackingSDK', '~> 1.0'
end
```

### Installation

```bash
pod install
```

### Import in Swift

```swift
import InhouseTrackingSDK

InhouseTrackingSDK.shared.initialize(
    projectId: "your_project_id",
    projectToken: "your_project_token",
    shortLinkDomain: "tryinhouse.com"
)
```

## Best Practices

1. **Version Management**: Always use semantic versioning (MAJOR.MINOR.PATCH)
2. **Git Tags**: Create git tags for each release
3. **Documentation**: Keep README.md updated with usage examples
4. **Testing**: Test your pod locally before publishing
5. **Validation**: Always validate podspec before pushing
6. **Changelog**: Maintain a CHANGELOG.md for version history

## Support

If you encounter issues:

1. Check CocoaPods documentation: https://guides.cocoapods.org/
2. Check CocoaPods issues: https://github.com/CocoaPods/CocoaPods/issues
3. Validate your podspec: `pod spec lint --help`

## Example Complete Workflow

```bash
# 1. Setup repository
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/tryinhouse/tracking-sdk-ios.git
git push -u origin main

# 2. Create tag
git tag -a v1.0.0 -m "Version 1.0.0"
git push origin v1.0.0

# 3. Validate podspec
pod spec lint InhouseTrackingSDK.podspec

# 4. Push to CocoaPods
pod trunk push InhouseTrackingSDK.podspec

# 5. Verify
pod search InhouseTrackingSDK
```

This completes the CocoaPods publishing process for your InhouseTrackingSDK!
