import Foundation
import UIKit
import os.log

@objc public class EventTracker: NSObject {
    
    private let networkClient: NetworkClient
    private let storageManager: StorageManager
    private let config: SDKConfig
    private let logger = Logger(subsystem: "InhouseTrackingSDK", category: "events")
    
    @objc public init(networkClient: NetworkClient, storageManager: StorageManager, config: SDKConfig) {
        self.networkClient = networkClient
        self.storageManager = storageManager
        self.config = config
        super.init()
    }
    
    // MARK: - Public Methods
    
    @objc public func trackEvent(eventType: String, shortLink: String? = nil, completion: ((String) -> Void)? = nil) {
        logger.debug("trackEvent called with eventType=\(eventType), shortLink=\(shortLink ?? "nil")")
        
        let event = createEvent(eventType: eventType, shortLink: shortLink)
        logger.debug("Event created: \(event)")
        
        sendEvent(event) { responseJson in
            self.logger.debug("trackEvent callback: \(responseJson)")
            completion?(responseJson)
        }
    }
    
    @objc public func trackShortLinkClick(shortLink: String, deepLink: String?, completion: ((String) -> Void)? = nil) {
        logger.debug("trackShortLinkClick called with shortLink=\(shortLink), deepLink=\(deepLink ?? "nil")")
        
        let event = createEvent(eventType: "short_link_click", shortLink: shortLink, deepLink: deepLink)
        logger.debug("Event created: \(event)")
        
        sendEvent(event) { responseJson in
            self.logger.debug("trackShortLinkClick callback: \(responseJson)")
            completion?(responseJson)
        }
    }
    
    @objc public func trackAppInstall(shortLink: String, completion: ((String) -> Void)? = nil) {
        logger.debug("trackAppInstall called with shortLink=\(shortLink)")
        
        // First, get key-value pairs from server
        networkClient.getInstallData(shortLink: shortLink) { [weak self] installData in
            guard let self = self else { return }
            
            self.logger.debug("Install data received: \(installData)")
            
            // Store the key-value pairs
            let installDataObj = InstallData(shortLink: shortLink, keyValuePairs: installData)
            self.storageManager.storeInstallData(installDataObj)
            
            // Track install event
            let event = self.createEvent(eventType: "app_install", shortLink: shortLink, additionalData: installData)
            self.logger.debug("Event created: \(event)")
            
            self.sendEvent(event) { responseJson in
                self.logger.debug("trackAppInstall callback: \(responseJson)")
                completion?(responseJson)
            }
            
            if self.config.enableDebugLogging {
                self.logger.debug("App install tracked with data: \(installData)")
            }
        }
    }
    
    @objc public func trackCustomEvent(eventType: String, shortLink: String?, additionalData: [String: String]?, completion: ((String) -> Void)? = nil) {
        logger.debug("trackCustomEvent called with eventType=\(eventType), shortLink=\(shortLink ?? "nil"), additionalData=\(additionalData?.description ?? "nil")")
        
        let event = createEvent(eventType: eventType, shortLink: shortLink, additionalData: additionalData)
        logger.debug("Event created: \(event)")
        
        sendEvent(event) { responseJson in
            self.logger.debug("trackCustomEvent callback: \(responseJson)")
            completion?(responseJson)
        }
    }
    
    // MARK: - Private Methods
    
    private func createEvent(
        eventType: String,
        shortLink: String? = nil,
        deepLink: String? = nil,
        additionalData: [String: String]? = nil
    ) -> Event {
        logger.debug("createEvent called with eventType=\(eventType), shortLink=\(shortLink ?? "nil"), deepLink=\(deepLink ?? "nil"), additionalData=\(additionalData?.description ?? "nil")")
        
        var extra: [String: Any] = [:]
        
        // Device info
        extra["device"] = UIDevice.current.name
        extra["device_model"] = UIDevice.current.model
        extra["device_vendor"] = "Apple"
        extra["os"] = "iOS"
        extra["os_version"] = UIDevice.current.systemVersion
        extra["cpu_architecture"] = getCPUArchitecture()
        extra["platform"] = "iOS"
        extra["app_version"] = getAppVersion()
        extra["build_number"] = getBuildNumber()
        extra["bundle_identifier"] = getBundleIdentifier()
        
        // Add additional data if provided
        if let additionalData = additionalData {
            for (key, value) in additionalData {
                extra[key] = value
            }
        }
        
        return Event(
            eventType: eventType,
            projectId: config.projectId,
            projectToken: config.projectToken,
            shortLink: shortLink,
            deepLink: deepLink,
            deviceId: storageManager.getDeviceId(),
            sessionId: InhouseTrackingSDK.shared.getSessionId(),
            extra: extra,
            userAgent: getUserAgent(),
            ipAddress: nil // iOS doesn't provide direct access to IP address
        )
    }
    
    private func sendEvent(_ event: Event, completion: @escaping (String) -> Void) {
        networkClient.sendEvent(event) { responseJson in
            completion(responseJson)
        }
    }
    
    // MARK: - Device Information
    
    private func getCPUArchitecture() -> String {
        #if arch(x86_64)
        return "x86_64"
        #elseif arch(arm64)
        return "arm64"
        #elseif arch(arm)
        return "arm"
        #else
        return "unknown"
        #endif
    }
    
    private func getAppVersion() -> String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
    
    private func getBuildNumber() -> String {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }
    
    private func getBundleIdentifier() -> String {
        return Bundle.main.bundleIdentifier ?? "Unknown"
    }
    
    private func getUserAgent() -> String {
        return "InhouseTrackingSDK/1.0 iOS/\(UIDevice.current.systemVersion)"
    }
} 