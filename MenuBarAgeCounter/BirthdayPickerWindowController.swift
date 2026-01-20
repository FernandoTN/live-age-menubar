import AppKit

/// A window controller for selecting a birthday date
final class BirthdayPickerWindowController: NSWindowController {
    private var datePicker: NSDatePicker!
    private var saveButton: NSButton!
    private var cancelButton: NSButton!
    private var yearPopUp: NSPopUpButton!
    private var monthPopUp: NSPopUpButton!

    convenience init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 320, height: 360),
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

        // Year label
        let yearLabel = NSTextField(labelWithString: "Year:")
        yearLabel.font = NSFont.systemFont(ofSize: 12)
        yearLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(yearLabel)

        // Year dropdown
        yearPopUp = NSPopUpButton()
        yearPopUp.translatesAutoresizingMaskIntoConstraints = false
        let currentYear = Calendar.current.component(.year, from: Date())
        for year in stride(from: currentYear, through: 1900, by: -1) {
            yearPopUp.addItem(withTitle: String(year))
        }
        yearPopUp.target = self
        yearPopUp.action = #selector(yearMonthChanged)
        contentView.addSubview(yearPopUp)

        // Month label
        let monthLabel = NSTextField(labelWithString: "Month:")
        monthLabel.font = NSFont.systemFont(ofSize: 12)
        monthLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(monthLabel)

        // Month dropdown
        monthPopUp = NSPopUpButton()
        monthPopUp.translatesAutoresizingMaskIntoConstraints = false
        let monthNames = ["January", "February", "March", "April", "May", "June",
                          "July", "August", "September", "October", "November", "December"]
        for month in monthNames {
            monthPopUp.addItem(withTitle: month)
        }
        monthPopUp.target = self
        monthPopUp.action = #selector(yearMonthChanged)
        contentView.addSubview(monthPopUp)

        // Date picker (graphical calendar, date only)
        datePicker = NSDatePicker()
        datePicker.datePickerStyle = .clockAndCalendar
        datePicker.datePickerElements = [.yearMonthDay]
        datePicker.dateValue = BirthdaySettingsManager.shared.birthdayOrDefault
        datePicker.maxDate = Date()
        datePicker.target = self
        datePicker.action = #selector(datePickerChanged)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(datePicker)

        // Sync dropdowns with initial date
        updateDropdownsFromDatePicker()

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

            // Year controls
            yearLabel.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 16),
            yearLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            yearLabel.centerYAnchor.constraint(equalTo: yearPopUp.centerYAnchor),

            yearPopUp.leadingAnchor.constraint(equalTo: yearLabel.trailingAnchor, constant: 6),
            yearPopUp.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 12),
            yearPopUp.widthAnchor.constraint(equalToConstant: 80),

            // Month controls
            monthLabel.leadingAnchor.constraint(equalTo: yearPopUp.trailingAnchor, constant: 16),
            monthLabel.centerYAnchor.constraint(equalTo: monthPopUp.centerYAnchor),

            monthPopUp.leadingAnchor.constraint(equalTo: monthLabel.trailingAnchor, constant: 6),
            monthPopUp.topAnchor.constraint(equalTo: yearPopUp.topAnchor),
            monthPopUp.widthAnchor.constraint(equalToConstant: 100),

            // Date picker
            datePicker.topAnchor.constraint(equalTo: yearPopUp.bottomAnchor, constant: 12),
            datePicker.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            saveButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            cancelButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            cancelButton.trailingAnchor.constraint(equalTo: saveButton.leadingAnchor, constant: -12)
        ])
    }

    /// Updates the date picker when year or month dropdown changes
    @objc private func yearMonthChanged() {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())

        // Get selected year (dropdown is in descending order: currentYear, currentYear-1, ...)
        let selectedYearIndex = yearPopUp.indexOfSelectedItem
        let selectedYear = currentYear - selectedYearIndex

        // Get selected month (0-indexed)
        let selectedMonth = monthPopUp.indexOfSelectedItem + 1

        // Get current day from date picker, clamped to valid range for new month
        var day = calendar.component(.day, from: datePicker.dateValue)

        // Clamp day to valid range for the selected month/year
        var components = DateComponents()
        components.year = selectedYear
        components.month = selectedMonth
        components.day = 1
        if let firstOfMonth = calendar.date(from: components),
           let range = calendar.range(of: .day, in: .month, for: firstOfMonth) {
            day = min(day, range.count)
        }

        components.day = day
        if let newDate = calendar.date(from: components) {
            // Don't allow future dates
            let clampedDate = min(newDate, Date())
            datePicker.dateValue = clampedDate
            // Update dropdowns in case date was clamped
            updateDropdownsFromDatePicker()
        }
    }

    /// Updates the dropdowns when the calendar date picker changes
    @objc private func datePickerChanged() {
        updateDropdownsFromDatePicker()
    }

    /// Syncs the year and month dropdowns to match the date picker's current value
    private func updateDropdownsFromDatePicker() {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        let selectedYear = calendar.component(.year, from: datePicker.dateValue)
        let selectedMonth = calendar.component(.month, from: datePicker.dateValue)

        // Year dropdown index (descending order: currentYear at 0, currentYear-1 at 1, etc.)
        let yearIndex = currentYear - selectedYear
        if yearIndex >= 0 && yearIndex < yearPopUp.numberOfItems {
            yearPopUp.selectItem(at: yearIndex)
        }

        // Month dropdown index (0-indexed, January = 0)
        let monthIndex = selectedMonth - 1
        if monthIndex >= 0 && monthIndex < monthPopUp.numberOfItems {
            monthPopUp.selectItem(at: monthIndex)
        }
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
