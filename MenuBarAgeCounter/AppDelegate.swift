import AppKit
import ServiceManagement

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var textView: StatusBarTextView?
    private var updateTimer: Timer?
    private let ageCalculator = AgeCalculator()

    private let launchAtLoginKey = "launchAtLogin"

    private weak var breakdownMenuItem: NSMenuItem?
    private weak var birthdateMenuItem: NSMenuItem?
    private var birthdayWindowController: BirthdayPickerWindowController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()
        startTimer()
        setupBirthdayObserver()

        // Show birthday picker on first launch
        if BirthdaySettingsManager.shared.isFirstLaunch || !BirthdaySettingsManager.shared.hasBirthdaySet {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.showBirthdayPicker()
            }
        }
    }

    private func setupBirthdayObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(birthdayDidChange),
            name: .birthdayDidChange,
            object: nil
        )
    }

    @objc private func birthdayDidChange() {
        updateBirthdateMenuItem()
    }

    private func updateBirthdateMenuItem() {
        birthdateMenuItem?.title = ageCalculator.getFormattedBirthday()
    }

    private func setupStatusItem() {
        // Calculate fixed width for "XX.XXXXXX" format to avoid layout recalculations
        let font = NSFont.monospacedDigitSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)
        let sampleText = "00.000000"
        let textSize = (sampleText as NSString).size(withAttributes: [.font: font])
        let fixedWidth = ceil(textSize.width) + 4

        // Use fixed length instead of variableLength to prevent layout changes
        statusItem = NSStatusBar.system.statusItem(withLength: fixedWidth)

        if let button = statusItem?.button {
            // Create custom text view that uses direct drawing
            textView = StatusBarTextView(frame: button.bounds)
            textView?.font = font
            textView?.text = sampleText
            textView?.translatesAutoresizingMaskIntoConstraints = false

            // Clear default button content and add our custom view
            button.title = ""
            button.addSubview(textView!)
        }

        setupMenu()
    }

    private func setupMenu() {
        let menu = NSMenu()

        // Age breakdown header
        let breakdownItem = NSMenuItem(title: ageCalculator.getDetailedBreakdown(), action: nil, keyEquivalent: "")
        breakdownItem.isEnabled = false
        menu.addItem(breakdownItem)
        self.breakdownMenuItem = breakdownItem

        // Birthdate display
        let birthdateItem = NSMenuItem(title: ageCalculator.getFormattedBirthday(), action: nil, keyEquivalent: "")
        birthdateItem.isEnabled = false
        menu.addItem(birthdateItem)
        self.birthdateMenuItem = birthdateItem

        // Set Birthday menu item
        let setBirthdayItem = NSMenuItem(
            title: "Set Birthday...",
            action: #selector(showBirthdayPicker),
            keyEquivalent: "b"
        )
        setBirthdayItem.keyEquivalentModifierMask = .command
        setBirthdayItem.target = self
        menu.addItem(setBirthdayItem)

        menu.addItem(NSMenuItem.separator())

        // Launch at Login toggle
        let launchAtLoginItem = NSMenuItem(
            title: "Launch at Login",
            action: #selector(toggleLaunchAtLogin(_:)),
            keyEquivalent: ""
        )
        launchAtLoginItem.target = self
        launchAtLoginItem.state = isLaunchAtLoginEnabled() ? .on : .off
        menu.addItem(launchAtLoginItem)

        menu.addItem(NSMenuItem.separator())

        // Quit
        let quitItem = NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem?.menu = menu
    }

    @objc private func showBirthdayPicker() {
        if birthdayWindowController == nil {
            birthdayWindowController = BirthdayPickerWindowController()
        }
        birthdayWindowController?.showWindow()
    }

    private func startTimer() {
        updateTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateAge()
        }
        updateTimer?.tolerance = 0.01 // 10% tolerance for power efficiency
        RunLoop.current.add(updateTimer!, forMode: .common)
    }

    private func updateAge() {
        // Direct text update via custom view - bypasses layout system
        textView?.text = ageCalculator.getFormattedAge()

        // Update the menu breakdown periodically
        breakdownMenuItem?.title = ageCalculator.getDetailedBreakdown()
    }

    // MARK: - Launch at Login

    private func isLaunchAtLoginEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey: launchAtLoginKey)
    }

    @objc private func toggleLaunchAtLogin(_ sender: NSMenuItem) {
        let newState = !isLaunchAtLoginEnabled()
        UserDefaults.standard.set(newState, forKey: launchAtLoginKey)
        sender.state = newState ? .on : .off

        if #available(macOS 13.0, *) {
            do {
                if newState {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
            } catch {
                print("Failed to \(newState ? "enable" : "disable") launch at login: \(error)")
            }
        }
    }

    @objc private func quitApp() {
        NSApplication.shared.terminate(nil)
    }

    func applicationWillTerminate(_ notification: Notification) {
        updateTimer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
}
