import AppKit

/// A window controller for selecting a birthday date
final class BirthdayPickerWindowController: NSWindowController {
    private var datePicker: NSDatePicker!
    private var saveButton: NSButton!
    private var cancelButton: NSButton!

    convenience init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 150),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "Set Birthday"
        window.center()
        window.isReleasedWhenClosed = false

        self.init(window: window)
        setupUI()
    }

    private func setupUI() {
        guard let contentView = window?.contentView else { return }

        // Label
        let label = NSTextField(labelWithString: "Select your birthday:")
        label.font = NSFont.systemFont(ofSize: 13)
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)

        // Date picker (date only, no time)
        datePicker = NSDatePicker()
        datePicker.datePickerStyle = .textFieldAndStepper
        datePicker.datePickerElements = [.yearMonthDay]
        datePicker.dateValue = BirthdaySettingsManager.shared.birthdayOrDefault
        datePicker.maxDate = Date()
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(datePicker)

        // Cancel button
        cancelButton = NSButton(title: "Cancel", target: self, action: #selector(cancelClicked))
        cancelButton.bezelStyle = .rounded
        cancelButton.keyEquivalent = "\u{1b}" // Escape key
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cancelButton)

        // Save button
        saveButton = NSButton(title: "Save", target: self, action: #selector(saveClicked))
        saveButton.bezelStyle = .rounded
        saveButton.keyEquivalent = "\r" // Enter key
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(saveButton)

        // Layout constraints
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),

            datePicker.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 12),
            datePicker.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            saveButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            cancelButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            cancelButton.trailingAnchor.constraint(equalTo: saveButton.leadingAnchor, constant: -12)
        ])
    }

    @objc private func saveClicked() {
        // Set the time to midnight (00:00:00) for the selected date
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: datePicker.dateValue)
        if let midnightDate = calendar.date(from: components) {
            BirthdaySettingsManager.shared.birthday = midnightDate
        }
        close()
    }

    @objc private func cancelClicked() {
        close()
    }

    func showWindow() {
        window?.center()
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
