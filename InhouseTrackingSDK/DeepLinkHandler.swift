import Foundation
import os.log

@objc public class DeepLinkHandler: NSObject {
    
    private weak var trackingSDK: InhouseTrackingSDK?
    private let config: SDKConfig
    private let logger = Logger(subsystem: "InhouseTrackingSDK", category: "deeplink")
    
    @objc public init(trackingSDK: InhouseTrackingSDK, config: SDKConfig) {
        self.trackingSDK = trackingSDK
        self.config = config
        super.init()
    }
    
    // MARK: - Public Methods
    
    @objc public func handleDeepLink(_ url: URL) -> Bool {
        logger.debug("handleDeepLink called with url=\(url.absoluteString)")
        
        // Check if this is a shortlink
        if let shortLinkDetector = trackingSDK?.publicShortLinkDetector,
           shortLinkDetector.isShortLink(url.absoluteString) {
            logger.debug("Deep link is a shortlink: \(url.absoluteString)")
            
            // Track the shortlink click
            trackingSDK?.trackShortLinkClick(shortLink: url.absoluteString, deepLink: url.absoluteString) { responseJson in
                self.logger.debug("Shortlink click tracked: \(responseJson)")
            }
            
            return true
        }
        
        // Check for shortlink in query parameters
        if let shortLink = extractShortLinkFromURL(url) {
            logger.debug("Shortlink found in deep link: \(shortLink)")
            
            // Track the shortlink click
            trackingSDK?.trackShortLinkClick(shortLink: shortLink, deepLink: url.absoluteString) { responseJson in
                self.logger.debug("Shortlink click tracked: \(responseJson)")
            }
            
            return true
        }
        
        logger.debug("No shortlink found in deep link")
        return false
    }
    
    @objc public func extractShortLinkFromURL(_ url: URL) -> String? {
        logger.debug("extractShortLinkFromURL called with url=\(url.absoluteString)")
        
        // Check query parameters
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
            // Check for shortlink parameter
            if let shortLink = components.queryItems?.first(where: { $0.name.lowercased() == "shortlink" })?.value {
                logger.debug("Shortlink found in query parameter: \(shortLink)")
                return shortLink
            }
            
            // Check for utm_source with shortlink domain
            if let utmSource = components.queryItems?.first(where: { $0.name.lowercased() == "utm_source" })?.value,
               utmSource.contains(config.shortLinkDomain) {
                logger.debug("Shortlink found in utm_source: \(utmSource)")
                return utmSource
            }
        }
        
        // Check fragment
        if let fragment = url.fragment, !fragment.isEmpty {
            let fragmentComponents = fragment.components(separatedBy: "&")
            for component in fragmentComponents {
                let keyValue = component.components(separatedBy: "=")
                if keyValue.count == 2 && keyValue[0].lowercased() == "shortlink" {
                    let shortLink = keyValue[1]
                    logger.debug("Shortlink found in fragment: \(shortLink)")
                    return shortLink
                }
            }
        }
        
        logger.debug("No shortlink found in URL")
        return nil
    }
    
    @objc public func processAppLaunchURL(_ url: URL) {
        logger.debug("processAppLaunchURL called with url=\(url.absoluteString)")
        
        if handleDeepLink(url) {
            logger.debug("Deep link processed successfully")
        } else {
            logger.debug("Deep link did not contain shortlink")
        }
    }
} 