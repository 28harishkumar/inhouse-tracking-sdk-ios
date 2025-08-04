import UIKit

class ViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        title = "Tracking SDK Example"
        view.backgroundColor = .systemBackground
        
        // Setup scroll view
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Setup stack view
        scrollView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.distribution = .fill
        stackView.alignment = .fill
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])
        
        setupButtons()
    }
    
    private func setupButtons() {
        // Info section
        let infoLabel = UILabel()
        infoLabel.text = "Tracking SDK Test Buttons"
        infoLabel.font = UIFont.boldSystemFont(ofSize: 18)
        infoLabel.textAlignment = .center
        stackView.addArrangedSubview(infoLabel)
        
        // Track App Open
        let trackAppOpenButton = createButton(title: "Track App Open", action: #selector(trackAppOpen))
        stackView.addArrangedSubview(trackAppOpenButton)
        
        // Track App Open from ShortLink
        let trackAppOpenShortLinkButton = createButton(title: "Track App Open from ShortLink", action: #selector(trackAppOpenFromShortLink))
        stackView.addArrangedSubview(trackAppOpenShortLinkButton)
        
        // Track Session Start
        let trackSessionStartButton = createButton(title: "Track Session Start", action: #selector(trackSessionStart))
        stackView.addArrangedSubview(trackSessionStartButton)
        
        // Track Session Start from ShortLink
        let trackSessionStartShortLinkButton = createButton(title: "Track Session Start from ShortLink", action: #selector(trackSessionStartFromShortLink))
        stackView.addArrangedSubview(trackSessionStartShortLinkButton)
        
        // Track ShortLink Click
        let trackShortLinkClickButton = createButton(title: "Track ShortLink Click", action: #selector(trackShortLinkClick))
        stackView.addArrangedSubview(trackShortLinkClickButton)
        
        // Track App Install from ShortLink
        let trackAppInstallButton = createButton(title: "Track App Install from ShortLink", action: #selector(trackAppInstallFromShortLink))
        stackView.addArrangedSubview(trackAppInstallButton)
        
        // Track Custom Event
        let trackCustomEventButton = createButton(title: "Track Custom Event", action: #selector(trackCustomEvent))
        stackView.addArrangedSubview(trackCustomEventButton)
        
        // Get Device Info
        let getDeviceInfoButton = createButton(title: "Get Device Info", action: #selector(getDeviceInfo))
        stackView.addArrangedSubview(getDeviceInfoButton)
        
        // Get Session Info
        let getSessionInfoButton = createButton(title: "Get Session Info", action: #selector(getSessionInfo))
        stackView.addArrangedSubview(getSessionInfoButton)
        
        // Test Deep Link
        let testDeepLinkButton = createButton(title: "Test Deep Link", action: #selector(testDeepLink))
        stackView.addArrangedSubview(testDeepLinkButton)
        
        // Reset First Install (for testing)
        let resetFirstInstallButton = createButton(title: "Reset First Install", action: #selector(resetFirstInstall))
        stackView.addArrangedSubview(resetFirstInstallButton)
    }
    
    private func createButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
    
    // MARK: - Button Actions
    
    @objc private func trackAppOpen() {
        InhouseTrackingSDK.shared.trackAppOpen { response in
            DispatchQueue.main.async {
                self.showAlert(title: "Track App Open", message: response)
            }
        }
    }
    
    @objc private func trackAppOpenFromShortLink() {
        let shortLink = "https://tryinhouse.com/test123"
        InhouseTrackingSDK.shared.trackAppOpenFromShortLink(shortLink: shortLink) { response in
            DispatchQueue.main.async {
                self.showAlert(title: "Track App Open from ShortLink", message: response)
            }
        }
    }
    
    @objc private func trackSessionStart() {
        InhouseTrackingSDK.shared.trackSessionStart { response in
            DispatchQueue.main.async {
                self.showAlert(title: "Track Session Start", message: response)
            }
        }
    }
    
    @objc private func trackSessionStartFromShortLink() {
        let shortLink = "https://tryinhouse.com/test123"
        InhouseTrackingSDK.shared.trackSessionStartFromShortLink(shortLink: shortLink) { response in
            DispatchQueue.main.async {
                self.showAlert(title: "Track Session Start from ShortLink", message: response)
            }
        }
    }
    
    @objc private func trackShortLinkClick() {
        let shortLink = "https://tryinhouse.com/test123"
        let deepLink = "myapp://test?param=value"
        InhouseTrackingSDK.shared.trackShortLinkClick(shortLink: shortLink, deepLink: deepLink) { response in
            DispatchQueue.main.async {
                self.showAlert(title: "Track ShortLink Click", message: response)
            }
        }
    }
    
    @objc private func trackAppInstallFromShortLink() {
        let shortLink = "https://tryinhouse.com/test123"
        InhouseTrackingSDK.shared.trackAppInstallFromShortLink(shortLink: shortLink) { response in
            DispatchQueue.main.async {
                self.showAlert(title: "Track App Install from ShortLink", message: response)
            }
        }
    }
    
    @objc private func trackCustomEvent() {
        let additionalData = ["custom_param": "custom_value", "test_param": "test_value"]
        InhouseTrackingSDK.shared.trackCustomEvent(eventType: "custom_event", additionalData: additionalData) { response in
            DispatchQueue.main.async {
                self.showAlert(title: "Track Custom Event", message: response)
            }
        }
    }
    
    @objc private func getDeviceInfo() {
        let deviceId = InhouseTrackingSDK.shared.getDeviceId()
        let message = "Device ID: \(deviceId)"
        showAlert(title: "Device Info", message: message)
    }
    
    @objc private func getSessionInfo() {
        let sessionId = InhouseTrackingSDK.shared.getSessionId()
        let message = "Session ID: \(sessionId)"
        showAlert(title: "Session Info", message: message)
    }
    
    @objc private func testDeepLink() {
        let testURL = URL(string: "https://tryinhouse.com/test123?utm_source=test&utm_medium=app")!
        InhouseTrackingSDK.shared.onNewURL(testURL)
        showAlert(title: "Test Deep Link", message: "Deep link test triggered")
    }
    
    @objc private func resetFirstInstall() {
        InhouseTrackingSDK.shared.resetFirstInstall()
        showAlert(title: "Reset First Install", message: "First install flag has been reset")
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
} 