import Foundation

extension Notification.Name {
    static let birthdayDidChange = Notification.Name("birthdayDidChange")
}

/// Manages birthday persistence using UserDefaults
final class BirthdaySettingsManager {
    static let shared = BirthdaySettingsManager()

    private let birthdayKey = "userBirthday"
    private let hasLaunchedBeforeKey = "hasLaunchedBefore"

    private init() {}

    /// Returns the stored birthday, or nil if not set
    var birthday: Date? {
        get {
            return UserDefaults.standard.object(forKey: birthdayKey) as? Date
        }
        set {
            UserDefaults.standard.set(newValue, forKey: birthdayKey)
            NotificationCenter.default.post(name: .birthdayDidChange, object: nil)
        }
    }

    /// Returns the stored birthday or a default date (Jan 1, 2000) if not set
    var birthdayOrDefault: Date {
        if let birthday = birthday {
            return birthday
        }
        // Default: January 1, 2000 at 00:00
        var components = DateComponents()
        components.year = 2000
        components.month = 1
        components.day = 1
        components.hour = 0
        components.minute = 0
        components.second = 0
        let calendar = Calendar(identifier: .gregorian)
        return calendar.date(from: components) ?? Date()
    }

    /// Returns true if this is the first launch of the app
    var isFirstLaunch: Bool {
        if UserDefaults.standard.bool(forKey: hasLaunchedBeforeKey) {
            return false
        }
        UserDefaults.standard.set(true, forKey: hasLaunchedBeforeKey)
        return true
    }

    /// Returns true if a birthday has been set by the user
    var hasBirthdaySet: Bool {
        return birthday != nil
    }
}
