import Foundation
import os.log
import AdSupport
import AppTrackingTransparency
import StoreKit
import UIKit
#if canImport(CoreTelephony)
import CoreTelephony
#endif

@objc public class InstallReferrerManager: NSObject {
    
    private let storageManager: StorageManager
    private let logger = Logger(subsystem: "InhouseTrackingSDK", category: "referrer")
    
    @objc public init(storageManager: StorageManager) {
        self.storageManager = storageManager
        super.init()
    }
    
    // MARK: - Public Methods
    
    /// Attempts to retrieve the install referrer for the app.
    /// This will check for a stored referrer, attempt to fetch from App Store attribution,
    /// fallback to IDFA if available, and finally use device fingerprinting via remote API.
    @objc public func getInstallReferrer(callback: @escaping (String?) -> Void) {
        logger.debug("getInstallReferrer called")
        
        // 1. Check if we have a stored referrer
        if let storedReferrer = storageManager.getInstallReferrer() {
            logger.debug("Found stored install referrer: \(storedReferrer)")
            callback(storedReferrer)
            return
        }
        
        // 2. Try to get App Store attribution (SKAdNetwork/StoreKit 2)
        getAppStoreReferrer { [weak self] referrer in
            if let referrer = referrer, !referrer.isEmpty {
                self?.logger.debug("App Store referrer found: \(referrer)")
                self?.storageManager.storeInstallReferrer(referrer)
                callback(referrer)
                return
            }
            
            // 3. Fallback: Try to get IDFA (if user has granted permission)
            self?.getIDFA { idfa in
                if let idfa = idfa, !idfa.isEmpty {
                    self?.logger.debug("IDFA used as fallback referrer: \(idfa)")
                    self?.storageManager.storeInstallReferrer("idfa=\(idfa)")
                    callback("idfa=\(idfa)")
                } else {
                    // 4. Fallback: Use device fingerprinting via remote API
                    self?.logger.debug("No install referrer or IDFA available, using remote fingerprinting")
                    self?.getFingerprintReferrer { fingerprintReferrer in
                        if let fingerprintReferrer = fingerprintReferrer, !fingerprintReferrer.isEmpty {
                            self?.logger.debug("Fingerprint referrer received: \(fingerprintReferrer)")
                            self?.storageManager.storeInstallReferrer(fingerprintReferrer)
                            callback(fingerprintReferrer)
                        } else {
                            self?.logger.debug("No install referrer available after fingerprinting")
                            callback(nil)
                        }
                    }
                }
            }
        }
    }
    
    /// Store a custom install referrer string (e.g., from a deep link or campaign)
    @objc public func storeInstallReferrer(_ referrer: String) {
        logger.debug("storeInstallReferrer called with referrer=\(referrer)")
        storageManager.storeInstallReferrer(referrer)
    }
    
    // MARK: - Private Methods
    
    /// Attempts to fetch App Store attribution data using StoreKit 2 (iOS 15+).
    /// If not available, returns nil.
    private func getAppStoreReferrer(callback: @escaping (String?) -> Void) {
        logger.debug("getAppStoreReferrer called")
        if #available(iOS 16.0, *) {
            Task {
                do {
                    // Use SKAdNetwork.attributionToken() for iOS 16+
                    // let attribution = try await SKAdNetwork.attributionToken()
                    // if !attribution.isEmpty {
                    //     logger.debug("SKAdNetwork attribution token found")
                    //     callback("skadnetwork_token=\(attribution)")
                    //     return
                    // }
                } catch {
                    logger.error("Failed to get SKAdNetwork attribution token: \(error.localizedDescription)")
                }
                callback(nil)
            }
        } else {
            callback(nil)
        }
    }
    
    /// Attempts to get the IDFA (Identifier for Advertisers) if user has granted permission.
    private func getIDFA(callback: @escaping (String?) -> Void) {
        logger.debug("getIDFA called")
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                if status == .authorized {
                    let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                    if idfa != "00000000-0000-0000-0000-000000000000" {
                        callback(idfa)
                        return
                    }
                }
                callback(nil)
            }
        } else {
            let idfa = ASIdentifierManager.shared().isAdvertisingTrackingEnabled ? ASIdentifierManager.shared().advertisingIdentifier.uuidString : nil
            if let idfa = idfa, idfa != "00000000-0000-0000-0000-000000000000" {
                callback(idfa)
            } else {
                callback(nil)
            }
        }
    }
    
    /// Collects as much device information as possible and sends it to the remote fingerprinting API.
    /// If a referrer is returned, it is saved and returned via callback.
    private func getFingerprintReferrer(callback: @escaping (String?) -> Void) {
        logger.debug("getFingerprintReferrer called")
        
        var info: [String: Any] = [:]
        
        // Device info
        let device = UIDevice.current
        info["model"] = device.model
        info["systemName"] = device.systemName
        info["systemVersion"] = device.systemVersion
        info["name"] = device.name
        info["identifierForVendor"] = device.identifierForVendor?.uuidString ?? ""
        
        // Screen info
        let screen = UIScreen.main
        let bounds = screen.bounds
        info["screenWidth"] = Int(bounds.width)
        info["screenHeight"] = Int(bounds.height)
        info["scale"] = screen.scale
        
        // Locale and timezone
        info["locale"] = Locale.current.identifier
        info["timezone"] = TimeZone.current.identifier
        
        // App info
        if let infoDict = Bundle.main.infoDictionary {
            info["bundleIdentifier"] = Bundle.main.bundleIdentifier ?? ""
            info["appVersion"] = infoDict["CFBundleShortVersionString"] as? String ?? ""
            info["buildNumber"] = infoDict["CFBundleVersion"] as? String ?? ""
        }
        
        // Network info (if available)
        if let carrierName = getCarrierName() {
            info["carrier"] = carrierName
        }
        
        // Battery info
        device.isBatteryMonitoringEnabled = true
        info["batteryLevel"] = device.batteryLevel
        info["batteryState"] = device.batteryState.rawValue
        
        // Orientation
        info["orientation"] = device.orientation.rawValue
        
        // Accessibility
        info["isVoiceOverRunning"] = UIAccessibility.isVoiceOverRunning
        info["isReduceMotionEnabled"] = UIAccessibility.isReduceMotionEnabled
        
        // Time since boot
        info["uptime"] = ProcessInfo.processInfo.systemUptime
        
        // Send to remote API
        guard let url = URL(string: "https://api.tryinhouse.co/api/check-fingureprinting") else {
            logger.error("Invalid fingerprinting API URL")
            callback(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: info, options: [])
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        } catch {
            logger.error("Failed to serialize fingerprinting info: \(error.localizedDescription)")
            callback(nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                self?.logger.error("Fingerprinting API request failed: \(error.localizedDescription)")
                callback(nil)
                return
            }
            guard let data = data else {
                self?.logger.error("Fingerprinting API returned no data")
                callback(nil)
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let referrer = json["referrer"] as? String, !referrer.isEmpty {
                    self?.logger.debug("Fingerprinting API returned referrer: \(referrer)")
                    callback(referrer)
                } else {
                    self?.logger.debug("Fingerprinting API returned no referrer")
                    callback(nil)
                }
            } catch {
                self?.logger.error("Failed to parse fingerprinting API response: \(error.localizedDescription)")
                callback(nil)
            }
        }
        task.resume()
    }
    
    /// Helper to get carrier name (if available)
    private func getCarrierName() -> String? {
        #if canImport(CoreTelephony)
        let networkInfo = CTTelephonyNetworkInfo()
        if let carrier = networkInfo.serviceSubscriberCellularProviders?.values.first {
            return carrier.carrierName
        }
        #endif
        return nil
    }
    
    /// Process App Store Connect attribution data (e.g., from Apple Search Ads or SKAdNetwork postbacks)
    @objc public func processAppStoreAttribution(_ attributionData: [String: Any]) {
        logger.debug("processAppStoreAttribution called with data: \(attributionData)")
        
        // Example: Store campaign and ad group IDs if present
        var referrerComponents: [String] = []
        if let campaignId = attributionData["campaign_id"] as? String {
            logger.debug("Campaign ID found: \(campaignId)")
            referrerComponents.append("campaign_id=\(campaignId)")
        }
        if let adGroupId = attributionData["ad_group_id"] as? String {
            logger.debug("Ad Group ID found: \(adGroupId)")
            referrerComponents.append("ad_group_id=\(adGroupId)")
        }
        if let creativeSetId = attributionData["creative_set_id"] as? String {
            logger.debug("Creative Set ID found: \(creativeSetId)")
            referrerComponents.append("creative_set_id=\(creativeSetId)")
        }
        if let keyword = attributionData["keyword"] as? String {
            logger.debug("Keyword found: \(keyword)")
            referrerComponents.append("keyword=\(keyword)")
        }
        if !referrerComponents.isEmpty {
            let referrerString = referrerComponents.joined(separator: "&")
            logger.debug("Storing combined referrer: \(referrerString)")
            storageManager.storeInstallReferrer(referrerString)
        }
    }
}