# iOS InhouseTrackingSDK

A comprehensive iOS SDK for tracking app installs, sessions, and user interactions with shortlinks and deep links.

## Features

- **App Install Tracking**: Track app installs from shortlinks
- **Session Management**: Track app opens and session starts
- **Deep Link Handling**: Automatic detection and processing of deep links
- **Shortlink Detection**: Extract and process shortlinks from various sources
- **Event Tracking**: Custom event tracking with additional data
- **Device Information**: Collect device and app information
- **Install Referrer**: Track install attribution data
- **Debug Logging**: Comprehensive logging for debugging

## Requirements

- iOS 13.0+
- Xcode 12.0+
- Swift 5.0+

## Installation

### Manual Installation

1. Add the `InhouseTrackingSDK` folder to your Xcode project
2. Import the SDK in your files: `import InhouseTrackingSDK`

### CocoaPods (Future)

```ruby
pod 'InhouseTrackingSDK', '~> 1.0'
```

## Setup and Configuration

### Prerequisites

1. **Apple Developer Account**: Required for Associated Domains capability
2. **Server Access**: Ability to configure your domain's `/.well-known/apple-app-site-association` file

### Complete Setup Steps

#### Step 1: Add SDK to Your Project

1. **Add the SDK files** to your Xcode project
2. **Import the SDK**: `import InhouseTrackingSDK`

#### Step 2: Configure URL Schemes

Add to your `Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>YOUR_BUNDLE_IDENTIFIER_LIKE_co.tryinhouse.InhouseTrackingSDKExample</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>YOUR_SCHEME_LIKE_inhouse-tracking</string>
        </array>
    </dict>
</array>
```

#### Step 3: Configure Universal Links

Add to your `Info.plist`:

```xml
<key>com.apple.developer.associated-domains</key>
<array>
    <string>applinks:YOUR_SHORT_LINK_SUB_DOMAIN.tryinhouse.co</string>
</array>
```

#### Step 4: Enable Associated Domains Capability

1. **In Apple Developer Portal**:

   - Go to Certificates, Identifiers & Profiles
   - Select your App ID
   - Enable "Associated Domains" capability
   - Download updated provisioning profile

2. **In Xcode**:
   - Select your target
   - Go to "Signing & Capabilities"
   - Click "+ Capability"
   - Add "Associated Domains"
   - Add your domains

#### Step 5: Configure Server

Create `/.well-known/apple-app-site-association` on your server:

```json
{
  "applinks": {
    "apps": [],
    "details": [
      {
        "appID": "TEAM_ID.YOUR_BUNDLE_INDTIFIER_LINK_co.tryinhouse.InhouseTrackingSDKExample",
        "paths": ["*"]
      }
    ]
  }
}
```

**Server Requirements**:

- HTTPS only
- No authentication required
- `Content-Type: application/json`
- Accessible at `https://yourdomain.com/.well-known/apple-app-site-association`

## Quick Start

### 1. Initialize the SDK

```swift
import InhouseTrackingSDK

// In your AppDelegate.swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    InhouseTrackingSDK.shared.initialize(
        projectId: "your_project_id",
        projectToken: "your_project_token",
        shortLinkDomain: "tryinhouse.com",
        serverUrl: "https://api.tryinhouse.com",
        enableDebugLogging: true
    ) { callbackType, jsonData in
        print("SDK Callback - Type: \(callbackType), Data: \(jsonData)")
    }

    return true
}
```

### 2. Handle Deep Links

```swift
// In your AppDelegate.swift
func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    InhouseTrackingSDK.shared.onNewURL(url)
    return true
}

// For Universal Links
func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
    if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
        if let url = userActivity.webpageURL {
            InhouseTrackingSDK.shared.onNewURL(url)
            return true
        }
    }
    return false
}
```

### 3. Track Events

```swift
// Track app open
InhouseTrackingSDK.shared.trackAppOpen { response in
    print("App open tracked: \(response)")
}

// Track app open from shortlink
InhouseTrackingSDK.shared.trackAppOpenFromShortLink(shortLink: "https://tryinhouse.com/test123") { response in
    print("App open from shortlink tracked: \(response)")
}

// Track session start
InhouseTrackingSDK.shared.trackSessionStart { response in
    print("Session start tracked: \(response)")
}

// Track shortlink click
InhouseTrackingSDK.shared.trackShortLinkClick(
    shortLink: "https://tryinhouse.com/test123",
    deepLink: "myapp://test?param=value"
) { response in
    print("Shortlink click tracked: \(response)")
}

// Track app install from shortlink
InhouseTrackingSDK.shared.trackAppInstallFromShortLink(shortLink: "https://tryinhouse.com/test123") { response in
    print("App install tracked: \(response)")
}

// Track custom event
let additionalData = ["custom_param": "custom_value"]
InhouseTrackingSDK.shared.trackCustomEvent(
    eventType: "custom_event",
    additionalData: additionalData
) { response in
    print("Custom event tracked: \(response)")
}
```

### 4. App Lifecycle Integration

```swift
// In your SceneDelegate.swift
func sceneDidBecomeActive(_ scene: UIScene) {
    InhouseTrackingSDK.shared.onAppResume()
}

func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    if let urlContext = URLContexts.first {
        InhouseTrackingSDK.shared.onNewURL(urlContext.url)
    }
}
```

## API Reference

### Initialization

```swift
func initialize(
    projectId: String,
    projectToken: String,
    shortLinkDomain: String,
    serverUrl: String = "https://api.tryinhouse.com",
    enableDebugLogging: Bool = false,
    callback: ((String, String) -> Void)? = nil
)
```

### Event Tracking Methods

- `trackAppOpen(shortLink: String?, callback: ((String) -> Void)?)`
- `trackAppOpenFromShortLink(shortLink: String, callback: ((String) -> Void)?)`
- `trackSessionStart(shortLink: String?, callback: ((String) -> Void)?)`
- `trackSessionStartFromShortLink(shortLink: String, callback: ((String) -> Void)?)`
- `trackShortLinkClick(shortLink: String, deepLink: String?, callback: ((String) -> Void)?)`
- `trackAppInstallFromShortLink(shortLink: String, callback: ((String) -> Void)?)`
- `trackCustomEvent(eventType: String, shortLink: String?, additionalData: [String: String]?, callback: ((String) -> Void)?)`

### Utility Methods

- `getSessionId() -> String`
- `getDeviceId() -> String`
- `getInstallReferrer() -> String?`
- `fetchInstallReferrer(callback: (String?) -> Void)`
- `onAppResume()`
- `onNewURL(_ url: URL?)`

### Testing Methods

- `resetFirstInstall()`
- `debugFirstInstallState()`

## Configuration

### URL Schemes

Add URL schemes to your `Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>com.yourcompany.yourapp</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>yourapp</string>
        </array>
    </dict>
</array>
```

### Universal Links

For Universal Links, you need to configure both your app and server:

#### 1. App Configuration

Add associated domains to your `Info.plist`:

```xml
<key>com.apple.developer.associated-domains</key>
<array>
    <string>applinks:YOUR_SHORT_LINK_SUB_DOMAIN.tryinhouse.com</string>
</array>
```

#### 2. Apple Developer Account Setup

1. **Enable Associated Domains Capability**:

   - Go to [Apple Developer Portal](https://developer.apple.com/account/)
   - Navigate to Certificates, Identifiers & Profiles
   - Select your App ID
   - Enable "Associated Domains" capability
   - Update your provisioning profile

2. **Add Associated Domains to Xcode**:
   - Open your project in Xcode
   - Select your target
   - Go to "Signing & Capabilities"
   - Click "+ Capability"
   - Add "Associated Domains"
   - Add your domains: `applinks:YOUR_SHORT_LINK_SUB_DOMAIN.tryinhouse.com`

#### 3. Server Configuration

Your server needs to serve an `apple-app-site-association` file at `/.well-known/apple-app-site-association`:

```json
{
  "applinks": {
    "apps": [],
    "details": [
      {
        "appID": "TEAM_ID.co.tryinhouse.InhouseTrackingSDKExample",
        "paths": ["*"]
      }
    ]
  }
}
```

**Important Notes**:

- Replace `TEAM_ID` with your actual Apple Team ID
- Replace `co.tryinhouse.InhouseTrackingSDKExample` with your actual bundle identifier
- The file must be served over HTTPS
- The file must be accessible without authentication
- The file must have `Content-Type: application/json`

#### 4. Testing Universal Links

1. **Build and install your app** on a device (Universal Links don't work in simulator)
2. **Test with Safari**: Open `https://tryinhouse.com/your-path` in Safari
3. **Test with other apps**: Share links from other apps to your app
4. **Verify in Settings**: Go to Settings > General > About > Legal & Regulatory > Universal Links

## Data Models

### SDKConfig

```swift
public class SDKConfig: NSObject {
    public let projectId: String
    public let projectToken: String
    public let shortLinkDomain: String
    public let serverUrl: String
    public let enableDebugLogging: Bool
    public let sessionTimeoutMinutes: Int
    public let maxRetryAttempts: Int
}
```

### Event

```swift
public class Event: NSObject, Codable {
    public let eventType: String
    public let projectId: String
    public let projectToken: String
    public let shortLink: String?
    public let deepLink: String?
    public let timestamp: Int64
    public let deviceId: String
    public let sessionId: String
    public let extra: [String: Any]?
    public let userAgent: String?
    public let ipAddress: String?
}
```

## Testing Deep Links

### Testing URL Schemes

Test custom URL schemes in simulator or device:

```bash
# Test in simulator
xcrun simctl openurl booted "inhouse-tracking://test?param=value"

# Test on device (replace UDID with your device UDID)
xcrun simctl openurl UDID "inhouse-tracking://test?param=value"
```

### Testing Universal Links

1. **On Device Only** (Universal Links don't work in simulator):

   - Build and install your app on a physical device
   - Open Safari and navigate to `https://tryinhouse.com/your-path`
   - The app should open automatically

2. **Test from Other Apps**:

   - Share a link from any app (Messages, Mail, etc.)
   - The link should open your app if it matches your domain

3. **Verify Universal Links**:
   - Go to Settings > General > About > Legal & Regulatory > Universal Links
   - Your app should appear in the list

### Debugging Universal Links

1. **Check Associated Domains**:

   - In Xcode, verify Associated Domains capability is added
   - Check that your domains are listed correctly

2. **Verify Server Configuration**:

   - Test your `apple-app-site-association` file: `https://yourdomain.com/.well-known/apple-app-site-association`
   - Ensure it returns valid JSON with correct `Content-Type`

3. **Check Apple's Validation**:
   - Apple validates your `apple-app-site-association` file
   - Check Apple's validation tool: https://search.developer.apple.com/appsearch-validation-tool/

## Example App

The SDK includes a comprehensive example app that demonstrates all features:

1. Open `ios-sdk/Example/InhouseTrackingSDKExample.xcodeproj`
2. Update the project ID and token in `AppDelegate.swift`
3. Build and run the app
4. Test various tracking scenarios using the UI buttons

## Architecture

The SDK is built with a modular architecture:

- **InhouseTrackingSDK**: Main SDK class with singleton pattern
- **EventTracker**: Handles event creation and tracking
- **NetworkClient**: Manages HTTP requests to the server
- **StorageManager**: Handles local data persistence
- **ShortLinkDetector**: Detects and extracts shortlinks
- **DeepLinkHandler**: Processes deep links and URLs
- **InstallReferrerManager**: Manages install attribution data

## Error Handling

The SDK includes comprehensive error handling and logging:

- Network errors are logged and reported via callbacks
- Invalid URLs are handled gracefully
- Missing data is handled with default values
- Debug logging can be enabled for troubleshooting

## Privacy

The SDK collects the following data:

- Device information (model, OS version, etc.)
- App information (version, bundle ID)
- Session and device IDs
- Event timestamps
- User-provided data

All data is transmitted securely over HTTPS and can be configured to respect user privacy preferences.

## Support

For support and questions, please contact the development team or refer to the API documentation.

## License

This SDK is proprietary software. Please refer to the license agreement for usage terms.
