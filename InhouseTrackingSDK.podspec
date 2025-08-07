Pod::Spec.new do |spec|
  spec.name         = "InhouseTrackingSDK"
  spec.version      = "1.0.4"
  spec.summary      = "A comprehensive iOS SDK for tracking app installs, sessions, and user interactions with shortlinks and deep links."
  spec.description  = <<-DESC
    InhouseTrackingSDK is a powerful iOS SDK that provides comprehensive tracking capabilities for app installs, sessions, and user interactions with shortlinks and deep links. It supports automatic deep link detection, event tracking, device information collection, and seamless integration with React Native and Flutter.
  DESC

  spec.homepage     = "https://github.com/28harishkumar/inhouse-tracking-sdk-ios"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "TryInHouse" => "support@tryinhouse.com" }
  spec.platform     = :ios, "16.0"
  spec.source       = { :git => "https://github.com/28harishkumar/inhouse-tracking-sdk-ios.git", :tag => "v#{spec.version}" }

  spec.source_files = "InhouseTrackingSDK/*.swift"
  spec.swift_version = "5.0"
  
  # Enable Swift-to-Objective-C bridging
  spec.pod_target_xcconfig = {
    'SWIFT_INSTALL_OBJC_HEADER' => 'YES',
    'DEFINES_MODULE' => 'YES'
  }

  spec.frameworks = "Foundation", "UIKit", "AdSupport", "AppTrackingTransparency", "StoreKit"
  spec.weak_frameworks = "CoreTelephony"

  spec.requires_arc = true
end 