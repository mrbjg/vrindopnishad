import Foundation

public final class CacheService {
    public static let instance = CacheService()
    
    private init() {}
    
    // Memory Cache
    private var contentCache: [SacredContent]?
    private var categoryCache: [String: [SacredContent]] = [:]
    private var lastCacheTime: Date?
    
    private let contentCacheKey = "cached_content"
    private let cacheTimeKey = "cache_timestamp"
    private let cacheExpiry: TimeInterval = 24 * 60 * 60 // 24 hours in seconds
    
    public func getCachedContent() -> [SacredContent]? {
        if contentCache != nil && isCacheValid() {
            return contentCache
        }
        return nil
    }
    
    public func getCachedByCategory(category: String) -> [SacredContent]? {
        let key = category.lowercased()
        if let cached = categoryCache[key] {
            return cached
        }
        
        if let content = contentCache {
            let filtered = content.filter { $0.category.lowercased() == key }
            categoryCache[key] = filtered
            return filtered
        }
        
        return nil
    }
    
    public func cacheContent(_ content: [SacredContent]) {
        self.contentCache = content
        self.lastCacheTime = Date()
        self.categoryCache.removeAll()
        
        // Save to disk asynchronously in background
        DispatchQueue.global(qos: .background).async {
            self.saveToDisk(content)
        }
    }
    
    private func saveToDisk(_ content: [SacredContent]) {
        // SwiftData context takes care of caching database objects, but standard Codable fallback:
        UserDefaults.standard.set(Date(), forKey: cacheTimeKey)
    }
    
    private func isCacheValid() -> Bool {
        guard let lastCache = lastCacheTime else { return false }
        return Date().timeIntervalSince(lastCache) < cacheExpiry
    }
    
    public func clearCache() {
        contentCache = nil
        categoryCache.removeAll()
        lastCacheTime = nil
        UserDefaults.standard.removeObject(forKey: cacheTimeKey)
    }
    
    // MARK: - Daily Disk Caching Utilities
    
    private func cacheDailyString(key: String, jsonStr: String) {
        let todayStr = getTodayString()
        UserDefaults.standard.set(jsonStr, forKey: "\(key)_data")
        UserDefaults.standard.set(todayStr, forKey: "\(key)_date")
    }
    
    private func getDailyString(key: String) -> String? {
        let todayStr = getTodayString()
        let cachedDate = UserDefaults.standard.string(forKey: "\(key)_date")
        if cachedDate == todayStr {
            return UserDefaults.standard.string(forKey: "\(key)_data")
        }
        return nil
    }
    
    private func getTodayString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
    
    // MARK: - Daily Motivation Cache
    
    public func cacheDailyMotivation(_ motivation: DailyMotivation) {
        if let data = try? JSONEncoder().encode(motivation),
           let jsonStr = String(data: data, encoding: .utf8) {
            cacheDailyString(key: "daily_motivation", jsonStr: jsonStr)
        }
    }
    
    public func getCachedDailyMotivation() -> DailyMotivation? {
        guard let jsonStr = getDailyString(key: "daily_motivation"),
              let data = jsonStr.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(DailyMotivation.self, from: data)
    }
    
    // MARK: - Daily Gyaan Cache
    
    public func cacheDailyGyaan(_ gyaan: DailyGyaan) {
        if let data = try? JSONEncoder().encode(gyaan),
           let jsonStr = String(data: data, encoding: .utf8) {
            cacheDailyString(key: "daily_gyaan", jsonStr: jsonStr)
        }
    }
    
    public func getCachedDailyGyaan() -> DailyGyaan? {
        guard let jsonStr = getDailyString(key: "daily_gyaan"),
              let data = jsonStr.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(DailyGyaan.self, from: data)
    }
    
    // MARK: - Daily Challenges Cache
    
    public func cacheDailyChallenges(_ challenges: [DailyChallenge]) {
        if let data = try? JSONEncoder().encode(challenges),
           let jsonStr = String(data: data, encoding: .utf8) {
            cacheDailyString(key: "daily_challenges", jsonStr: jsonStr)
        }
    }
    
    public func getCachedDailyChallenges() -> [DailyChallenge]? {
        guard let jsonStr = getDailyString(key: "daily_challenges"),
              let data = jsonStr.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode([DailyChallenge].self, from: data)
    }
    
    // MARK: - Sacred Events Cache
    
    public func cacheUpcomingEvents(_ events: [SacredEvent]) {
        if let data = try? JSONEncoder().encode(events),
           let jsonStr = String(data: data, encoding: .utf8) {
            cacheDailyString(key: "upcoming_events", jsonStr: jsonStr)
        }
    }
    
    public func getCachedUpcomingEvents() -> [SacredEvent]? {
        guard let jsonStr = getDailyString(key: "upcoming_events"),
              let data = jsonStr.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode([SacredEvent].self, from: data)
    }
}
