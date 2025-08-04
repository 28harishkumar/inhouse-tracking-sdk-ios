import Foundation
import os.log

@objc public class ShortLinkDetector: NSObject {
    
    private let shortLinkDomain: String
    private let logger = Logger(subsystem: "InhouseTrackingSDK", category: "shortlink")
    
    @objc public init(shortLinkDomain: String) {
        self.shortLinkDomain = shortLinkDomain
        super.init()
    }
    
    // MARK: - Public Methods
    
    @objc public func isShortLink(_ url: String) -> Bool {
        logger.debug("isShortLink called with url=\(url)")
        
        guard let urlObj = URL(string: url) else {
            logger.debug("Invalid URL format: \(url)")
            return false
        }
        
        let host = urlObj.host?.lowercased() ?? ""
        let isShortLink = host.contains(shortLinkDomain.lowercased())
        
        logger.debug("URL host: \(host), shortLinkDomain: \(shortLinkDomain), isShortLink: \(isShortLink)")
        return isShortLink
    }
    
    @objc public func extractShortLink(from url: String) -> String? {
        logger.debug("extractShortLink called with url=\(url)")
        
        guard let urlObj = URL(string: url) else {
            logger.debug("Invalid URL format: \(url)")
            return nil
        }
        
        let host = urlObj.host?.lowercased() ?? ""
        
        // Check if this is a shortlink
        if host.contains(shortLinkDomain.lowercased()) {
            logger.debug("Shortlink extracted: \(url)")
            return url
        }
        
        // Check for shortlink in query parameters
        if let components = URLComponents(url: urlObj, resolvingAgainstBaseURL: false),
           let shortLinkParam = components.queryItems?.first(where: { $0.name.lowercased() == "shortlink" })?.value {
            logger.debug("Shortlink found in query parameter: \(shortLinkParam)")
            return shortLinkParam
        }
        
        // Check for shortlink in fragment
        if let fragment = urlObj.fragment, !fragment.isEmpty {
            // Try to extract shortlink from fragment
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
    
    @objc public func extractShortLinkFromReferrer(_ referrer: String) -> String? {
        logger.debug("extractShortLinkFromReferrer called with referrer=\(referrer)")
        
        // Try to extract shortlink from referrer string
        // This could be in various formats depending on the source
        
        // Check if the referrer itself is a shortlink
        if isShortLink(referrer) {
            logger.debug("Referrer is a shortlink: \(referrer)")
            return referrer
        }
        
        // Check for shortlink parameter
        if let shortLink = extractParameter(from: referrer, parameterName: "shortlink") {
            logger.debug("Shortlink found in referrer parameter: \(shortLink)")
            return shortLink
        }
        
        // Check for utm_source with shortlink domain
        if let utmSource = extractParameter(from: referrer, parameterName: "utm_source"),
           utmSource.contains(shortLinkDomain) {
            logger.debug("Shortlink found in utm_source: \(utmSource)")
            return utmSource
        }
        
        logger.debug("No shortlink found in referrer")
        return nil
    }
    
    // MARK: - Private Methods
    
    private func extractParameter(from urlString: String, parameterName: String) -> String? {
        guard let url = URL(string: urlString),
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return nil
        }
        
        return components.queryItems?.first(where: { $0.name.lowercased() == parameterName.lowercased() })?.value
    }
} 