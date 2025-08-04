import Foundation
import os.log

@objc public class StorageManager: NSObject {
    
    private let userDefaults = UserDefaults.standard
    private let logger = Logger(subsystem: "InhouseTrackingSDK", category: "storage")
    
    private enum Keys {
        static let deviceId = "tracking_sdk_device_id"
        static let firstInstall = "tracking_sdk_first_install"
        static let installData = "tracking_sdk_install_data"
        static let installReferrer = "tracking_sdk_install_referrer"
        static let failedEvents = "tracking_sdk_failed_events"
    }
    
    @objc public override init() {
        super.init()
    }
    
    // MARK: - Device ID
    
    @objc public func getDeviceId() -> String {
        if let deviceId = userDefaults.string(forKey: Keys.deviceId) {
            return deviceId
        } else {
            let deviceId = UUID().uuidString
            userDefaults.set(deviceId, forKey: Keys.deviceId)
            return deviceId
        }
    }
    
    // MARK: - First Install
    
    @objc public func isFirstInstall() -> Bool {
        let isFirst = !userDefaults.bool(forKey: Keys.firstInstall)
        let hasKey = userDefaults.object(forKey: Keys.firstInstall) != nil
        logger.debug("isFirstInstall() called, hasKey=\(hasKey), returning: \(isFirst)")
        return isFirst
    }
    
    @objc public func setFirstInstallComplete() {
        logger.debug("setFirstInstallComplete() called, setting first_install to true")
        userDefaults.set(true, forKey: Keys.firstInstall)
    }
    
    @objc public func resetFirstInstall() {
        logger.debug("resetFirstInstall() called, setting first_install to false")
        userDefaults.set(false, forKey: Keys.firstInstall)
    }
    
    @objc public func debugFirstInstallState() {
        let hasKey = userDefaults.object(forKey: Keys.firstInstall) != nil
        let value = userDefaults.bool(forKey: Keys.firstInstall)
        logger.debug("DEBUG: first_install key exists=\(hasKey), value=\(value)")
    }
    
    // MARK: - Install Data
    
    @objc public func storeInstallData(_ installData: InstallData) {
        do {
            let data = try JSONEncoder().encode(installData)
            userDefaults.set(data, forKey: Keys.installData)
        } catch {
            logger.error("Failed to store install data: \(error)")
        }
    }
    
    @objc public func getInstallData() -> InstallData? {
        guard let data = userDefaults.data(forKey: Keys.installData) else {
            return nil
        }
        
        do {
            return try JSONDecoder().decode(InstallData.self, from: data)
        } catch {
            logger.error("Failed to decode install data: \(error)")
            return nil
        }
    }
    
    // MARK: - Install Referrer
    
    @objc public func storeInstallReferrer(_ referrer: String) {
        userDefaults.set(referrer, forKey: Keys.installReferrer)
    }
    
    @objc public func getInstallReferrer() -> String? {
        return userDefaults.string(forKey: Keys.installReferrer)
    }
    
    // MARK: - Failed Events
    
    @objc public func storeFailedEvent(_ event: Event) {
        var existingEvents = getFailedEvents()
        existingEvents.append(event)
        
        // Keep only last 100 failed events
        if existingEvents.count > 100 {
            existingEvents.removeFirst()
        }
        
        do {
            let data = try JSONEncoder().encode(existingEvents)
            userDefaults.set(data, forKey: Keys.failedEvents)
        } catch {
            logger.error("Failed to store failed events: \(error)")
        }
    }
    
    @objc public func getFailedEvents() -> [Event] {
        guard let data = userDefaults.data(forKey: Keys.failedEvents) else {
            return []
        }
        
        do {
            return try JSONDecoder().decode([Event].self, from: data)
        } catch {
            logger.error("Failed to decode failed events: \(error)")
            return []
        }
    }
    
    @objc public func clearFailedEvents() {
        userDefaults.removeObject(forKey: Keys.failedEvents)
    }
} 