import Foundation
import SwiftData

// MARK: - UserStats
public struct UserStats: Codable, Equatable {
    public var firebaseUid: String
    public var level: Int
    public var experiencePoints: Int
    public var streakCount: Int
    public var lastActiveDate: Date?
    public var totalReadingMinutes: Int
    public var totalShlokasRead: Int
    public var totalJapCount: Int
    public var highestDailyJaps: Int
    public var dailyMalaGoal: Int
    public var reminderTime: String?
    public var dynamicIconEnabled: Bool
    public var spiritualityLevel: String // seeker, sadhak, tapasvi, siddha
    public var preferredLanguage: String
    public var onboardingCompleted: Bool
    public var totalBadges: Int
    public var updatedAt: Date

    public init(
        firebaseUid: String,
        level: Int = 1,
        experiencePoints: Int = 0,
        streakCount: Int = 0,
        lastActiveDate: Date? = nil,
        totalReadingMinutes: Int = 0,
        totalShlokasRead: Int = 0,
        totalJapCount: Int = 0,
        highestDailyJaps: Int = 0,
        dailyMalaGoal: Int = 11,
        reminderTime: String? = nil,
        dynamicIconEnabled: Bool = true,
        spiritualityLevel: String = "seeker",
        preferredLanguage: String = "hi",
        onboardingCompleted: Bool = false,
        totalBadges: Int = 0,
        updatedAt: Date = Date()
    ) {
        self.firebaseUid = firebaseUid
        self.level = level
        self.experiencePoints = experiencePoints
        self.streakCount = streakCount
        self.lastActiveDate = lastActiveDate
        self.totalReadingMinutes = totalReadingMinutes
        self.totalShlokasRead = totalShlokasRead
        self.totalJapCount = totalJapCount
        self.highestDailyJaps = highestDailyJaps
        self.dailyMalaGoal = dailyMalaGoal
        self.reminderTime = reminderTime
        self.dynamicIconEnabled = dynamicIconEnabled
        self.spiritualityLevel = spiritualityLevel
        self.preferredLanguage = preferredLanguage
        self.onboardingCompleted = onboardingCompleted
        self.totalBadges = totalBadges
        self.updatedAt = updatedAt
    }
}

// MARK: - JournalEntry
@Model
public final class JournalEntry {
    @Attribute(.unique) public var id: String
    public var firebaseUid: String
    public var title: String
    public var content: String
    public var createdAt: Date
    public var moonPhase: String?
    public var likedBy: [String]

    public init(
        id: String,
        firebaseUid: String,
        title: String,
        content: String,
        createdAt: Date = Date(),
        moonPhase: String? = nil,
        likedBy: [String] = []
    ) {
        self.id = id
        self.firebaseUid = firebaseUid
        self.title = title
        self.content = content
        self.createdAt = createdAt
        self.moonPhase = moonPhase
        self.likedBy = likedBy
    }
}

// MARK: - SacredContent
@Model
public final class SacredContent {
    @Attribute(.unique) public var id: String
    public var title: String
    public var category: String
    public var sanskritText: String
    public var translation: String
    public var hindiMeaning: String
    public var commentary: String
    public var imageUrl: String?
    public var audioUrl: String?
    public var author: String?
    public var book: String?
    public var section: String?
    public var chapter: String?
    public var heading: String?
    public var isFavorite: Bool = false
    public var contentTags: [String] = []
    public var audioTags: [String] = []
    public var videoTags: [String] = []
    public var imageTags: [String] = []

    public init(
        id: String,
        title: String,
        category: String,
        sanskritText: String,
        translation: String,
        hindiMeaning: String,
        commentary: String,
        imageUrl: String? = nil,
        audioUrl: String? = nil,
        author: String? = nil,
        book: String? = nil,
        section: String? = nil,
        chapter: String? = nil,
        heading: String? = nil,
        isFavorite: Bool = false,
        contentTags: [String] = [],
        audioTags: [String] = [],
        videoTags: [String] = [],
        imageTags: [String] = []
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.sanskritText = sanskritText
        self.translation = translation
        self.hindiMeaning = hindiMeaning
        self.commentary = commentary
        self.imageUrl = imageUrl
        self.audioUrl = audioUrl
        self.author = author
        self.book = book
        self.section = section
        self.chapter = chapter
        self.heading = heading
        self.isFavorite = isFavorite
        self.contentTags = contentTags
        self.audioTags = audioTags
        self.videoTags = videoTags
        self.imageTags = imageTags
    }

    public var displayTitle: String {
        title.replacingOccurrences(of: "\n", with: ", ")
    }

    public var raga: String? {
        let allTags = contentTags + audioTags + videoTags + imageTags
        let knownRagas = [
            "yaman", "bhairavi", "bilaval", "darbari", "bhairav", "kalyan",
            "sarang", "brindavani sarang", "desh", "bhimpalasi", "malkauns",
            "vrindavani", "bageshri", "khamaj", "kafi", "pilu", "lalit", "todi"
        ]
        
        for tag in allTags {
            let lower = tag.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            if lower.hasPrefix("raga:") {
                return capitalizeRaga(String(lower.dropFirst(5).trimmingCharacters(in: .whitespacesAndNewlines)))
            } else if lower.hasPrefix("raga-") {
                return capitalizeRaga(String(lower.dropFirst(5).trimmingCharacters(in: .whitespacesAndNewlines)))
            } else if lower.hasPrefix("raga ") {
                return capitalizeRaga(String(lower.dropFirst(5).trimmingCharacters(in: .whitespacesAndNewlines)))
            } else if lower == "raga" {
                continue;
            } else if knownRagas.contains(lower) {
                return capitalizeRaga(lower)
            }
        }
        return nil
    }

    private func capitalizeRaga(_ s: String) -> String {
        if s.isEmpty { return s }
        return s.components(separatedBy: " ").map { word in
            guard !word.isEmpty else { return "" }
            return word.prefix(1).uppercased() + word.dropFirst()
        }.joined(separator: " ")
    }

    public var displayImageUrl: String {
        if let img = imageUrl, !img.isEmpty, img != "assets/vaani_icon.png" {
            return img
        }
        
        let shlokaImages = [
            "https://images.unsplash.com/photo-1512290923902-8a9f81dc236c?auto=format&fit=crop&w=500&q=80",
            "https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=500&q=80",
            "https://images.unsplash.com/photo-1470813740244-df37b8c1edcb?auto=format&fit=crop&w=500&q=80",
            "https://images.unsplash.com/photo-1518241353330-0f7941c2d9b5?auto=format&fit=crop&w=500&q=80",
            "https://images.unsplash.com/photo-1506126613408-eca07ce68773?auto=format&fit=crop&w=500&q=80"
        ]
        let index = abs(id.hashValue) % shlokaImages.count
        return shlokaImages[index]
    }
}

// MARK: - DailyChallenge
public struct DailyChallenge: Codable, Identifiable {
    public var id: String
    public var title: String
    public var description: String?
    public var type: String // naam_jap, reading, ritual, meditation
    public var targetValue: Int
    public var xpReward: Int
    public var minLevel: Int
    public var date: Date?
    public var currentValue: Int
    public var createdAt: Date
    public var isCompleted: Bool
    public var completedAt: Date?

    public init(
        id: String,
        title: String,
        description: String? = nil,
        type: String,
        targetValue: Int,
        xpReward: Int = 100,
        minLevel: Int = 1,
        date: Date? = nil,
        currentValue: Int = 0,
        createdAt: Date = Date(),
        isCompleted: Bool = false,
        completedAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.type = type
        self.targetValue = targetValue
        self.xpReward = xpReward
        self.minLevel = minLevel
        self.date = date
        self.currentValue = currentValue
        self.createdAt = createdAt
        self.isCompleted = isCompleted
        self.completedAt = completedAt
    }

    public var progressPercent: Double {
        guard targetValue > 0 else { return 0.0 }
        return Double(currentValue) / Double(targetValue)
    }

    public var typeIcon: String {
        switch type {
        case "naam_jap": return "Jap"
        case "reading": return "Read"
        case "ritual": return "Ritual"
        case "meditation": return "Dhyan"
        default: return "Sadhana"
        }
    }

    public var typeLabel: String {
        switch type {
        case "naam_jap": return "Naam Jap"
        case "reading": return "Reading"
        case "ritual": return "Ritual"
        case "meditation": return "Meditation"
        default: return "Spiritual"
        }
    }
}

// MARK: - DailyGyaan
public struct DailyGyaan: Codable, Identifiable {
    public var id: String
    public var title: String
    public var content: String
    public var mediaUrl: String?
    public var mediaType: String? // image, video, audio
    public var difficulty: Int // 1=beginner, 2=intermediate, 3=advanced
    public var category: String?
    public var createdAt: Date

    public init(
        id: String,
        title: String,
        content: String,
        mediaUrl: String? = nil,
        mediaType: String? = nil,
        difficulty: Int = 1,
        category: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.mediaUrl = mediaUrl
        self.mediaType = mediaType
        self.difficulty = difficulty
        self.category = category
        self.createdAt = createdAt
    }
}

// MARK: - DailyMotivation
public struct DailyMotivation: Codable, Identifiable {
    public var id: String
    public var content: String
    public var source: String?
    public var minLevel: Int
    public var maxLevel: Int
    public var category: String // general, naam_jap, reading, sadhana
    public var language: String
    public var createdAt: Date

    public init(
        id: String,
        content: String,
        source: String? = nil,
        minLevel: Int = 1,
        maxLevel: Int = 99,
        category: String = "general",
        language: String = "hi",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.content = content
        self.source = source
        self.minLevel = minLevel
        self.maxLevel = maxLevel
        self.category = category
        self.language = language
        self.createdAt = createdAt
    }
}

// MARK: - SacredEvent
public struct SacredEvent: Codable, Identifiable {
    public var id: String
    public var title: String
    public var description: String?
    public var date: Date
    public var type: String // vrat, utsav, tithi, ekadashi, purnima
    public var isRecurring: Bool
    public var imageUrl: String?
    public var createdAt: Date

    public init(
        id: String,
        title: String,
        description: String? = nil,
        date: Date,
        type: String,
        isRecurring: Bool = false,
        imageUrl: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.date = date
        self.type = type
        self.isRecurring = isRecurring
        self.imageUrl = imageUrl
        self.createdAt = createdAt
    }

    public var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }

    public var isUpcoming: Bool {
        let now = Date()
        guard let diff = Calendar.current.dateComponents([.day], from: now, to: date).day else { return false }
        return diff >= 0 && diff <= 7
    }

    public var typeLabel: String {
        switch type {
        case "vrat": return "व्रत"
        case "utsav": return "उत्सव"
        case "tithi": return "तिथि"
        case "ekadashi": return "एकादशी"
        case "purnima": return "पूर्णिमा"
        default: return "आध्यात्मिक"
        }
    }
}

// MARK: - Ritual
public struct Ritual: Codable, Identifiable {
    public var id: String
    public var title: String
    public var time: String // e.g. "06:30 AM"
    public var subtitle: String? // e.g. "12 Rounds"
    public var category: String // e.g. "Morning", "Afternoon", "Evening"
    public var isCompleted: Bool
    public var updatedAt: Date

    public init(
        id: String,
        title: String,
        time: String,
        subtitle: String? = nil,
        category: String,
        isCompleted: Bool = false,
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.time = time
        self.subtitle = subtitle
        self.category = category
        self.isCompleted = isCompleted
        self.updatedAt = updatedAt
    }
}

// MARK: - Achievement
public struct Achievement: Codable, Identifiable {
    public var id: String
    public var title: String
    public var description: String
    public var icon: String // emoji
    public var xpBonus: Int
    public var condition: String // streak_count, total_jap_count, etc
    public var targetValue: Int
    public var isUnlocked: Bool
    public var unlockedAt: Date?

    public init(
        id: String,
        title: String,
        description: String,
        icon: String,
        xpBonus: Int = 100,
        condition: String,
        targetValue: Int,
        isUnlocked: Bool = false,
        unlockedAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.icon = icon
        self.xpBonus = xpBonus
        self.condition = condition
        self.targetValue = targetValue
        self.isUnlocked = isUnlocked
        self.unlockedAt = unlockedAt
    }

    public static var allAchievements: [Achievement] {
        [
            Achievement(id: "pranaam", title: "प्रणाम", description: "Complete your first spiritual session", icon: "🌅", xpBonus: 50, condition: "total_jap_count", targetValue: 1),
            Achievement(id: "agni_7", title: "अग्नि", description: "Maintain a 7-day streak", icon: "🔥", xpBonus: 200, condition: "streak_count", targetValue: 7),
            Achievement(id: "agni_30", title: "महाअग्नि", description: "Maintain a 30-day streak", icon: "🔥", xpBonus: 1000, condition: "streak_count", targetValue: 30),
            Achievement(id: "mala_master", title: "माला मास्टर", description: "Complete 108 malas total", icon: "📿", xpBonus: 500, condition: "total_malas", targetValue: 108),
            Achievement(id: "vidya", title: "विद्या", description: "Read 50 shlokas", icon: "📖", xpBonus: 300, condition: "total_shlokas_read", targetValue: 50),
            Achievement(id: "dhyana", title: "ध्यान", description: "Complete 30 rituals", icon: "🧘", xpBonus: 400, condition: "rituals_completed", targetValue: 30),
            Achievement(id: "tapasvi", title: "तपस्वी", description: "Reach Level 16", icon: "⭐", xpBonus: 1000, condition: "level", targetValue: 16),
            Achievement(id: "siddha", title: "सिद्ध", description: "Reach Level 31", icon: "🏔️", xpBonus: 2000, condition: "level", targetValue: 31),
            Achievement(id: "sahasra", title: "सहस्र", description: "Complete 1008 chants in a single day", icon: "👑", xpBonus: 500, condition: "daily_jap_count", targetValue: 1008)
        ]
    }
}
