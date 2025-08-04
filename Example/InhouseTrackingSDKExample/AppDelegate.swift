import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Initialize the Tracking SDK
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

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
    
    // MARK: - Deep Link Handling
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print("App opened with URL: \(url.absoluteString)")
        
        // Handle the deep link with the SDK
        InhouseTrackingSDK.shared.onNewURL(url)
        
        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            if let url = userActivity.webpageURL {
                print("Universal link opened: \(url.absoluteString)")
                InhouseTrackingSDK.shared.onNewURL(url)
                return true
            }
        }
        return false
    }
} 