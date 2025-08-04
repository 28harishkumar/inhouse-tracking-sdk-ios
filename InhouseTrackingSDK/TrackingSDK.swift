import Foundation
import UIKit
import os.log

@objc public class InhouseTrackingSDK: NSObject {
    
    // MARK: - Singleton
    @objc public static let shared = InhouseTrackingSDK()
    
    // MARK: - Properties
    private var config: SDKConfig?
    private var eventTracker: EventTracker?
    private var networkClient: NetworkClient?
    private var storageManager: StorageManager?
    private var shortLinkDetector: ShortLinkDetector?
    private var deepLinkHandler: DeepLinkHandler?
    private var sdkCallback: ((String, String) -> Void)?
    private var currentViewController: UIViewController?
    
    private let sessionId = UUID().uuidString
    private let logger = Logger(subsystem: "InhouseTrackingSDK", category: "main")
    
    // MARK: - Computed Properties for External Access
    @objc public var publicShortLinkDetector: ShortLinkDetector? {
        return self.shortLinkDetector
    }
    
    private override init() {
        super.init()
    }
    
    // MARK: - Public Methods
    
    /// Initialize the SDK with project token and shortlink domain
    /// - Parameters:
    ///   - projectId: The project ID
    ///   - projectToken: The project token
    ///   - shortLinkDomain: The shortlink domain
    ///   - serverUrl: The server URL (optional)
    ///   - enableDebugLogging: Enable debug logging (optional)
    ///   - callback: Callback for SDK events
    @objc public func initialize(
        projectId: String,
        projectToken: String,
        shortLinkDomain: String,
        serverUrl: String = "https://api.tryinhouse.com",
        enableDebugLogging: Bool = false,
        callback: ((String, String) -> Void)? = nil
    ) {
        logger.debug("initialize called with projectId=\(projectId), projectToken=\(projectToken), shortLinkDomain=\(shortLinkDomain), serverUrl=\(serverUrl), enableDebugLogging=\(enableDebugLogging)")
        
        self.config = SDKConfig(
            projectId: projectId,
            projectToken: projectToken,
            shortLinkDomain: shortLinkDomain,
            serverUrl: serverUrl,
            enableDebugLogging: enableDebugLogging
        )
        self.sdkCallback = callback
        
        initializeComponents()
        handleAppLaunch()
        
        if enableDebugLogging {
            logger.debug("SDK initialized with domain: \(shortLinkDomain)")
        }
    }
    
    // MARK: - Tracking Methods
    
    @objc public func trackAppOpen(shortLink: String? = nil, callback: ((String) -> Void)? = nil) {
        logger.debug("trackAppOpen called with shortLink=\(shortLink ?? "nil")")
        eventTracker?.trackEvent(eventType: "app_open", shortLink: shortLink) { responseJson in
            self.logger.debug("trackAppOpen callback: \(responseJson)")
            callback?(responseJson)
        }
    }
    
    @objc public func trackAppOpenFromShortLink(shortLink: String, callback: ((String) -> Void)? = nil) {
        logger.debug("trackAppOpenFromShortLink called with shortLink=\(shortLink)")
        eventTracker?.trackEvent(eventType: "app_open_shortlink", shortLink: shortLink) { responseJson in
            self.logger.debug("trackAppOpenFromShortLink callback: \(responseJson)")
            callback?(responseJson)
        }
    }
    
    @objc public func trackSessionStart(shortLink: String? = nil, callback: ((String) -> Void)? = nil) {
        logger.debug("trackSessionStart called with shortLink=\(shortLink ?? "nil")")
        eventTracker?.trackEvent(eventType: "session_start", shortLink: shortLink) { responseJson in
            self.logger.debug("trackSessionStart callback: \(responseJson)")
            callback?(responseJson)
        }
    }
    
    @objc public func trackSessionStartFromShortLink(shortLink: String, callback: ((String) -> Void)? = nil) {
        logger.debug("trackSessionStartFromShortLink called with shortLink=\(shortLink)")
        eventTracker?.trackEvent(eventType: "session_start_shortlink", shortLink: shortLink) { responseJson in
            self.logger.debug("trackSessionStartFromShortLink callback: \(responseJson)")
            callback?(responseJson)
        }
    }
    
    @objc public func trackShortLinkClick(shortLink: String, deepLink: String? = nil, callback: ((String) -> Void)? = nil) {
        logger.debug("trackShortLinkClick called with shortLink=\(shortLink), deepLink=\(deepLink ?? "nil")")
        eventTracker?.trackShortLinkClick(shortLink: shortLink, deepLink: deepLink) { responseJson in
            self.logger.debug("trackShortLinkClick callback: \(responseJson)")
            callback?(responseJson)
        }
    }
    
    @objc public func trackAppInstallFromShortLink(shortLink: String, callback: ((String) -> Void)? = nil) {
        logger.debug("trackAppInstallFromShortLink called with shortLink=\(shortLink)")
        eventTracker?.trackAppInstall(shortLink: shortLink) { responseJson in
            self.logger.debug("trackAppInstallFromShortLink callback: \(responseJson)")
            callback?(responseJson)
        }
    }
    
    @objc public func trackCustomEvent(eventType: String, shortLink: String? = nil, additionalData: [String: String]? = nil, callback: ((String) -> Void)? = nil) {
        logger.debug("trackCustomEvent called with eventType=\(eventType), shortLink=\(shortLink ?? "nil"), additionalData=\(additionalData?.description ?? "nil")")
        eventTracker?.trackCustomEvent(eventType: eventType, shortLink: shortLink, additionalData: additionalData) { responseJson in
            self.logger.debug("trackCustomEvent callback: \(responseJson)")
            callback?(responseJson)
        }
    }
    
    @objc public func setCurrentViewController(_ viewController: UIViewController?) {
        logger.debug("setCurrentViewController called with viewController=\(viewController?.description ?? "nil")")
        self.currentViewController = viewController
    }
    
    @objc public func onAppResume() {
        logger.debug("onAppResume called")
        checkForShortLinkOpen(isAppResume: true)
    }
    
    @objc public func onNewURL(_ url: URL?) {
        logger.debug("onNewURL called with url: \(url?.absoluteString ?? "nil")")
        checkForShortLinkOpen(url: url, isAppResume: true)
    }
    
    // MARK: - Utility Methods
    
    @objc public func getSessionId() -> String {
        return sessionId
    }
    
    @objc public func getDeviceId() -> String {
        return storageManager?.getDeviceId() ?? ""
    }
    
    @objc public func getInstallReferrer() -> String? {
        return storageManager?.getInstallReferrer()
    }
    
    @objc public func fetchInstallReferrer(callback: @escaping (String?) -> Void) {
        guard let storageManager = storageManager else {
            logger.error("StorageManager is null in fetchInstallReferrer")
            callback(nil)
            return
        }
        
        let installReferrerManager = InstallReferrerManager(storageManager: storageManager)
        installReferrerManager.getInstallReferrer(callback: callback)
    }
    
    // MARK: - Testing Methods
    
    @objc public func resetFirstInstall() {
        logger.debug("resetFirstInstall called")
        storageManager?.resetFirstInstall()
    }
    
    @objc public func debugFirstInstallState() {
        logger.debug("debugFirstInstallState called")
        storageManager?.debugFirstInstallState()
    }
    
    // MARK: - Private Methods
    
    private func initializeComponents() {
        logger.debug("initializeComponents called")
        guard let config = config else {
            logger.error("Config is null in initializeComponents")
            return
        }
        
        storageManager = StorageManager()
        networkClient = NetworkClient(config: config)
        eventTracker = EventTracker(networkClient: networkClient!, storageManager: storageManager!, config: config)
        shortLinkDetector = ShortLinkDetector(shortLinkDomain: config.shortLinkDomain)
        deepLinkHandler = DeepLinkHandler(trackingSDK: self, config: config)
        logger.debug("Components initialized")
    }
    
    private func handleAppLaunch() {
        logger.debug("handleAppLaunch called")
        guard let storageManager = storageManager else {
            logger.error("StorageManager is null in handleAppLaunch")
            return
        }
        
        // Check if this is first launch after install
        if storageManager.isFirstInstall() {
            logger.debug("First install detected")
            handleFirstInstall()
        } else {
            logger.debug("Not first install, skipping first install logic")
        }
        
        // Check if app was opened from a shortlink
        checkForShortLinkOpen()
    }
    
    private func handleFirstInstall() {
        logger.debug("handleFirstInstall called")
        guard let storageManager = storageManager else {
            logger.error("StorageManager is null in handleFirstInstall")
            return
        }
        
        let installReferrer = storageManager.getInstallReferrer()
        
        if let installReferrer = installReferrer {
            logger.debug("Install referrer found: \(installReferrer)")
            let shortLink = shortLinkDetector?.extractShortLink(from: installReferrer)
            if let shortLink = shortLink {
                logger.debug("Shortlink extracted from install referrer: \(shortLink)")
                trackAppInstallFromShortLink(shortLink: shortLink) { responseJson in
                    self.logger.debug("App install from shortlink callback triggered: \(responseJson)")
                    self.sdkCallback?("app_install_from_shortlink", responseJson)
                }
            } else {
                logger.debug("No shortlink found in install referrer")
            }
            storageManager.setFirstInstallComplete()
        } else {
            // Referrer not yet available, fetch it asynchronously
            fetchInstallReferrer { referrer in
                if let referrer = referrer {
                    self.logger.debug("Install referrer fetched async: \(referrer)")
                    let shortLink = self.shortLinkDetector?.extractShortLink(from: referrer)
                    if let shortLink = shortLink {
                        self.logger.debug("Shortlink extracted from install referrer (async): \(shortLink)")
                        self.trackAppInstallFromShortLink(shortLink: shortLink) { responseJson in
                            self.logger.debug("App install from shortlink callback triggered (async): \(responseJson)")
                            self.sdkCallback?("app_install_from_shortlink", responseJson)
                        }
                    } else {
                        self.logger.debug("No shortlink found in install referrer (async)")
                    }
                } else {
                    self.logger.debug("No install referrer available after async fetch")
                }
                storageManager.setFirstInstallComplete()
            }
        }
    }
    
    private func checkForShortLinkOpen(url: URL? = nil, isAppResume: Bool = false) {
        logger.debug("checkForShortLinkOpen called with isAppResume=\(isAppResume)")
        
        let useURL = url ?? getCurrentURL()
        
        if let useURL = useURL, let shortLinkDetector = shortLinkDetector, shortLinkDetector.isShortLink(useURL.absoluteString) {
            let shortLink = useURL.absoluteString
            logger.debug("App opened from shortlink: \(shortLink)")
            
            if isAppResume {
                // When app comes to foreground, only track app open
                trackAppOpenFromShortLink(shortLink: shortLink) { responseJson in
                    self.logger.debug("App open from shortlink callback triggered (resume): \(responseJson)")
                    self.sdkCallback?("shortlink_click", responseJson)
                }
            } else {
                // When app is first opened, track all events
                trackShortLinkClick(shortLink: shortLink, deepLink: useURL.absoluteString) { responseJson in
                    self.logger.debug("Shortlink click callback triggered: \(responseJson)")
                    self.sdkCallback?("shortlink_click", responseJson)
                }
                trackSessionStartFromShortLink(shortLink: shortLink) { responseJson in
                    self.logger.debug("Session start from shortlink callback triggered: \(responseJson)")
                    self.sdkCallback?("session_start_from_shortlink", responseJson)
                }
            }
        } else {
            logger.debug("No shortlink data found in URL")
        }
    }
    
    private func getCurrentURL() -> URL? {
        // This would need to be implemented based on how your app handles deep links
        // For now, we'll return nil and let the app provide the URL via onNewURL
        return nil
    }
} 