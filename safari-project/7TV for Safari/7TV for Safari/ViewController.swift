//
//  ViewController.swift
//  7TV for Safari
//
import Cocoa
import SafariServices

let extensionBundleIdentifier = "\(Bundle.main.bundleIdentifier ?? "app.seventv.safari").Extension"

class ViewController: NSViewController {

    private let statusLabel = NSTextField(wrappingLabelWithString: "Checking extension status…")

    override func viewDidLoad() {
        super.viewDidLoad()

        configureInterface()
        refreshExtensionState()
    }

    private func configureInterface() {
        let iconView: NSImageView
        if let iconURL = Bundle.main.url(forResource: "Icon", withExtension: "png"),
           let icon = NSImage(contentsOf: iconURL) {
            iconView = NSImageView(image: icon)
        } else {
            iconView = NSImageView()
        }
        iconView.imageScaling = .scaleProportionallyUpOrDown
        iconView.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = NSTextField(labelWithString: "7TV for Safari (Unofficial)")
        titleLabel.font = .systemFont(ofSize: 24, weight: .semibold)
        titleLabel.alignment = .center

        statusLabel.alignment = .center
        statusLabel.textColor = .secondaryLabelColor
        statusLabel.maximumNumberOfLines = 3

        let openSettingsButton = NSButton(
            title: "Open Safari Settings…",
            target: self,
            action: #selector(openSafariSettings)
        )
        openSettingsButton.bezelStyle = .rounded
        openSettingsButton.controlSize = .large

        let permissionLabel = NSTextField(
            wrappingLabelWithString: "Enable the extension and allow access to Twitch and Kick."
        )
        permissionLabel.alignment = .center
        permissionLabel.textColor = .tertiaryLabelColor

        let stack = NSStackView(views: [iconView, titleLabel, statusLabel, openSettingsButton, permissionLabel])
        stack.orientation = .vertical
        stack.alignment = .centerX
        stack.spacing = 14
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.setCustomSpacing(20, after: statusLabel)
        stack.setCustomSpacing(18, after: openSettingsButton)

        view.addSubview(stack)
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 88),
            iconView.heightAnchor.constraint(equalToConstant: 88),
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 32),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -32),
            statusLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 340),
            permissionLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 340),
        ])
    }

    private func refreshExtensionState() {
        SFSafariExtensionManager.getStateOfSafariExtension(withIdentifier: extensionBundleIdentifier) { (state, error) in
            DispatchQueue.main.async {
                if let state = state, error == nil {
                    self.statusLabel.stringValue = state.isEnabled
                        ? "The Safari extension is enabled."
                        : "The Safari extension is installed but disabled."
                } else {
                    self.statusLabel.stringValue = "The extension is installed. Open Safari Settings to finish setup."
                }
            }
        }
    }

    @objc private func openSafariSettings() {
        statusLabel.stringValue = "Opening Safari Settings…"

        guard let safariURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.Safari") else {
            statusLabel.stringValue = "Safari could not be found. Open Safari > Settings > Extensions manually."
            return
        }

        let configuration = NSWorkspace.OpenConfiguration()
        configuration.activates = true

        NSWorkspace.shared.openApplication(at: safariURL, configuration: configuration) { _, launchError in
            DispatchQueue.main.async {
                guard launchError == nil else {
                    self.statusLabel.stringValue = "Safari could not be opened. Open Safari > Settings > Extensions manually."
                    return
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    SFSafariApplication.showPreferencesForExtension(withIdentifier: extensionBundleIdentifier) { error in
                        DispatchQueue.main.async {
                            let appleEventError = error == nil ? nil : self.openSafariExtensionsUsingAppleEvent()
                            if error == nil || appleEventError == nil {
                                self.statusLabel.stringValue = "Safari Settings opened. Enable 7TV for Safari (Unofficial)."
                            } else {
                                self.statusLabel.stringValue = "Safari opened. Select Safari > Settings > Extensions manually."
                            }
                        }
                    }
                }
            }
        }
    }

    private func openSafariExtensionsUsingAppleEvent() -> NSDictionary? {
        let scriptSource = """
        tell application id "com.apple.Safari"
            activate
            show extensions preferences "\(extensionBundleIdentifier)"
        end tell
        """
        var errorInfo: NSDictionary?
        NSAppleScript(source: scriptSource)?.executeAndReturnError(&errorInfo)
        return errorInfo
    }

}
