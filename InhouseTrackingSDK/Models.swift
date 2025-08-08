import Foundation

// MARK: - SDKConfig
@objc public class SDKConfig: NSObject {
    @objc public let projectId: String
    @objc public let projectToken: String
    @objc public let shortLinkDomain: String
    @objc public let serverUrl: String
    @objc public let enableDebugLogging: Bool
    @objc public let sessionTimeoutMinutes: Int
    @objc public let maxRetryAttempts: Int
    
    @objc public init(
        projectId: String,
        projectToken: String,
        shortLinkDomain: String,
        serverUrl: String = "https://api.tryinhouse.com",
        enableDebugLogging: Bool = false,
        sessionTimeoutMinutes: Int = 30,
        maxRetryAttempts: Int = 3
    ) {
        self.projectId = projectId
        self.projectToken = projectToken
        self.shortLinkDomain = shortLinkDomain
        self.serverUrl = serverUrl
        self.enableDebugLogging = enableDebugLogging
        self.sessionTimeoutMinutes = sessionTimeoutMinutes
        self.maxRetryAttempts = maxRetryAttempts
        super.init()
    }
}

// MARK: - Event
@objc public class Event: NSObject, Codable {
    @objc public let eventType: String
    @objc public let projectId: String
    @objc public let projectToken: String
    @objc public let shortLink: String?
    @objc public let deepLink: String?
    @objc public let timestamp: Int64
    @objc public let deviceId: String
    @objc public let sessionId: String
    @objc public let extra: [String: String]?
    @objc public let userAgent: String?
    @objc public let ipAddress: String?
    
    private enum CodingKeys: String, CodingKey {
        case eventType = "event_type"
        case projectId = "project_id"
        case projectToken = "project_token"
        case shortLink = "shortlink"
        case deepLink = "deep_link"
        case timestamp
        case deviceId = "device_id"
        case sessionId = "session_id"
        case extra
        case userAgent = "user_agent"
        case ipAddress = "ip_address"
    }
    
    @objc public init(
        eventType: String,
        projectId: String,
        projectToken: String,
        shortLink: String? = nil,
        deepLink: String? = nil,
        timestamp: Int64 = Int64(Date().timeIntervalSince1970 * 1000),
        deviceId: String,
        sessionId: String,
        extra: [String: String]? = nil,
        userAgent: String? = nil,
        ipAddress: String? = nil
    ) {
        self.eventType = eventType
        self.projectId = projectId
        self.projectToken = projectToken
        self.shortLink = shortLink
        self.deepLink = deepLink
        self.timestamp = timestamp
        self.deviceId = deviceId
        self.sessionId = sessionId
        self.extra = extra
        self.userAgent = userAgent
        self.ipAddress = ipAddress
        super.init()
    }
}

// MARK: - InstallData
@objc public class InstallData: NSObject, Codable {
    @objc public let shortLink: String
    @objc public let keyValuePairs: [String: String]
    @objc public let timestamp: Int64
    
    @objc public init(
        shortLink: String,
        keyValuePairs: [String: String],
        timestamp: Int64 = Int64(Date().timeIntervalSince1970 * 1000)
    ) {
        self.shortLink = shortLink
        self.keyValuePairs = keyValuePairs
        self.timestamp = timestamp
        super.init()
    }
} 