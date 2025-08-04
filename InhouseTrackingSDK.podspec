Pod::Spec.new do |spec|
  spec.name         = "InhouseTrackingSDK"
  spec.version      = "1.0.0"
  spec.summary      = "A comprehensive iOS SDK for tracking app installs, sessions, and user interactions with shortlinks and deep links."
  spec.description  = <<-DESC
    InhouseTrackingSDK is a powerful iOS SDK that provides comprehensive tracking capabilities for app installs, sessions, and user interactions with shortlinks and deep links. It supports automatic deep link detection, event tracking, device information collection, and seamless integration with React Native and Flutter.
  DESC

  spec.homepage     = "https://github.com/28harishkumar/inhouse-tracking-sdk-ios"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "TryInHouse" => "support@tryinhouse.com" }
  spec.platform     = :ios, "13.0"
  spec.source       = { :git => ".", :tag => "v#{spec.version}" }

  spec.source_files = "InhouseTrackingSDK/*.swift"
  spec.swift_version = "5.0"

  spec.frameworks = "Foundation", "UIKit"

  spec.requires_arc = true

  # Add any dependencies if needed
  # spec.dependency "SomeOtherPod", "~> 1.0"

  # Add any subspecs if needed
  # spec.subspec "Core" do |ss|
  #   ss.source_files = "InhouseTrackingSDK/Core/*.swift"
  # end

  # Add any resources if needed
  # spec.resource_bundles = {
  #   'InhouseTrackingSDK' => ['InhouseTrackingSDK/Resources/*']
  # }

  # Add any vendored frameworks if needed
  # spec.vendored_frameworks = "InhouseTrackingSDK/Frameworks/*.framework"

  # Add any vendored libraries if needed
  # spec.vendored_libraries = "InhouseTrackingSDK/Libraries/*.a"

  # Add any system frameworks if needed
  # spec.frameworks = "SystemConfiguration", "CoreTelephony"

  # Add any weak frameworks if needed
  # spec.weak_frameworks = "AdSupport", "iAd"

  # Add any libraries if needed
  # spec.libraries = "sqlite3", "z"

  # Add any compiler flags if needed
  # spec.compiler_flags = "-ObjC"

  # Add any pod target xcconfig if needed
  # spec.pod_target_xcconfig = { "OTHER_LDFLAGS" => "-ObjC" }

  # Add any user target xcconfig if needed
  # spec.user_target_xcconfig = { "OTHER_LDFLAGS" => "-ObjC" }

  # Add any deployment target if needed
  # spec.deployment_target = "13.0"

  # Add any test specs if needed
  # spec.test_spec do |test_spec|
  #   test_spec.source_files = "Tests/**/*.swift"
  #   test_spec.framework = "XCTest"
  # end
end 