import Foundation
import os.log

@objc public class NetworkClient: NSObject {
    
    private let config: SDKConfig
    private let logger = Logger(subsystem: "InhouseTrackingSDK", category: "network")
    private let session: URLSession
    
    @objc public init(config: SDKConfig) {
        self.config = config
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 30
        self.session = URLSession(configuration: configuration)
        
        super.init()
    }
    
    // MARK: - Event Tracking
    
    @objc public func sendEvent(_ event: Event, completion: @escaping (String) -> Void) {
        logger.debug("sendEvent called with eventType=\(event.eventType), projectId=\(event.projectId), projectToken=\(event.projectToken)")
        
        do {
            let jsonData = try JSONEncoder().encode(event)
            let jsonString = String(data: jsonData, encoding: .utf8) ?? "{}"
            
            guard let url = buildEventURL() else {
                logger.error("Failed to build URL for event registration")
                completion("{\"status\":\"error\",\"message\":\"Invalid URL\"}")
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("InhouseTrackingSDK/1.0", forHTTPHeaderField: "User-Agent")
            request.httpBody = jsonData
            
            logger.debug("Sending event to \(url.absoluteString) with body: \(jsonString)")
            
            let task = session.dataTask(with: request) { [weak self] data, response, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.logger.error("Network error sending event: \(error)")
                    completion("{\"status\":\"error\",\"message\":\"\(error.localizedDescription)\"}")
                    return
                }
                
                let responseString = String(data: data ?? Data(), encoding: .utf8) ?? "{}"
                self.logger.debug("Received response: \(responseString) with code: \((response as? HTTPURLResponse)?.statusCode ?? 0)")
                
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    if self.config.enableDebugLogging {
                        self.logger.debug("Event sent successfully: \(event.eventType)")
                    }
                    completion(responseString)
                } else {
                    self.logger.error("Failed to send event: \((response as? HTTPURLResponse)?.statusCode ?? 0)")
                    completion(responseString)
                }
            }
            
            task.resume()
            
        } catch {
            logger.error("Failed to encode event: \(error)")
            completion("{\"status\":\"error\",\"message\":\"Failed to encode event\"}")
        }
    }
    
    // MARK: - Install Data
    
    @objc public func getInstallData(shortLink: String, completion: @escaping ([String: String]) -> Void) {
        logger.debug("getInstallData called with shortLink=\(shortLink)")
        
        guard let url = buildInstallDataURL(shortLink: shortLink) else {
            logger.error("Failed to build install data URL")
            completion([:])
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("InhouseTrackingSDK/1.0", forHTTPHeaderField: "User-Agent")
        
        logger.debug("Requesting install data from \(url.absoluteString)")
        
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                self.logger.error("Network error getting install data: \(error)")
                completion([:])
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200,
               let data = data {
                do {
                    let jsonResponse = String(data: data, encoding: .utf8) ?? "{}"
                    self.logger.debug("Install data response: \(jsonResponse)")
                    
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: String] {
                        completion(json)
                    } else {
                        self.logger.error("Failed to parse install data response")
                        completion([:])
                    }
                } catch {
                    self.logger.error("Failed to parse install data: \(error)")
                    completion([:])
                }
            } else {
                self.logger.error("Failed to get install data: \((response as? HTTPURLResponse)?.statusCode ?? 0)")
                completion([:])
            }
        }
        
        task.resume()
    }
    
    // MARK: - Private Methods
    
    private func buildEventURL() -> URL? {
        var components = URLComponents(string: "\(config.serverUrl)/api/clicks/register_event")
        components?.queryItems = [
            URLQueryItem(name: "project_id", value: config.projectId),
            URLQueryItem(name: "project_token", value: config.projectToken)
        ]
        return components?.url
    }
    
    private func buildInstallDataURL(shortLink: String) -> URL? {
        var components = URLComponents(string: "\(config.serverUrl)/install-data")
        components?.queryItems = [
            URLQueryItem(name: "shortlink", value: shortLink),
            URLQueryItem(name: "project_id", value: config.projectId),
            URLQueryItem(name: "project_token", value: config.projectToken)
        ]
        return components?.url
    }
} 