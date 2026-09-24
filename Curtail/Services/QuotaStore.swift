import Foundation

enum QuotaStore {
    private static func key(_ name: String) -> String { "curtail.quota.\(name)" }

    private static func dayKey() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        return formatter.string(from: .now)
    }

    private static func monthKey() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMM"
        return formatter.string(from: .now)
    }

    static func dailyCount(_ name: String) -> Int {
        let store = UserDefaults.standard.dictionary(forKey: key(name)) as? [String: Int] ?? [:]
        return store[dayKey()] ?? 0
    }

    static func monthlyCount(_ name: String) -> Int {
        let store = UserDefaults.standard.dictionary(forKey: key(name)) as? [String: Int] ?? [:]
        return store[monthKey()] ?? 0
    }

    static func incrementDaily(_ name: String) {
        var store = UserDefaults.standard.dictionary(forKey: key(name)) as? [String: Int] ?? [:]
        store = store.filter { $0.key == dayKey() }
        store[dayKey(), default: 0] += 1
        UserDefaults.standard.set(store, forKey: key(name))
    }

    static func incrementMonthly(_ name: String) {
        var store = UserDefaults.standard.dictionary(forKey: key(name)) as? [String: Int] ?? [:]
        store = store.filter { $0.key == monthKey() }
        store[monthKey(), default: 0] += 1
        UserDefaults.standard.set(store, forKey: key(name))
    }

    static let freeCoachChatsPerDay = 5
    static let freeScansPerMonth = 2
    static let proScansPerMonth = 30
    static let proReportsPerMonth = 4
}
