import Foundation

class AgeCalculator {
    // Average days per year accounting for leap years
    private let daysPerYear: Double = 365.2425
    private let secondsPerYear: Double

    private var birthDate: Date

    init() {
        birthDate = BirthdaySettingsManager.shared.birthdayOrDefault
        secondsPerYear = daysPerYear * 24 * 60 * 60

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(birthdayDidChange),
            name: .birthdayDidChange,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func birthdayDidChange() {
        birthDate = BirthdaySettingsManager.shared.birthdayOrDefault
    }

    /// Returns the current age as a decimal with 6 decimal places
    func getFormattedAge() -> String {
        if !BirthdaySettingsManager.shared.hasBirthdaySet {
            return "00.000000"
        }
        let age = calculateAge()
        return String(format: "%.6f", age)
    }

    /// Returns the current age in years as a decimal
    func calculateAge() -> Double {
        let now = Date()
        let ageInSeconds = now.timeIntervalSince(birthDate)
        return ageInSeconds / secondsPerYear
    }

    /// Returns a detailed breakdown of the age
    func getDetailedBreakdown() -> String {
        if !BirthdaySettingsManager.shared.hasBirthdaySet {
            return "0y 0m 0d 0h 0m 0s"
        }

        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: birthDate,
            to: now
        )

        let years = components.year ?? 0
        let months = components.month ?? 0
        let days = components.day ?? 0
        let hours = components.hour ?? 0
        let minutes = components.minute ?? 0
        let seconds = components.second ?? 0

        return "\(years)y \(months)m \(days)d \(hours)h \(minutes)m \(seconds)s"
    }

    /// Returns the formatted birthday string for display
    func getFormattedBirthday() -> String {
        guard BirthdaySettingsManager.shared.hasBirthdaySet else {
            return "Birthday not set"
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return "Born: \(formatter.string(from: birthDate)) at 00:00"
    }
}
