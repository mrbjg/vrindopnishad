import Foundation

public enum SpiritualityLevel: String, CaseIterable, Codable {
    case seeker   // Level 1-5
    case sadhak   // Level 6-15
    case tapasvi  // Level 16-30
    case siddha   // Level 31+
}

public struct SpiritualityEngine {
    
    public static func detectLevel(userLevel: Int) -> SpiritualityLevel {
        if userLevel >= 31 { return .siddha }
        if userLevel >= 16 { return .tapasvi }
        if userLevel >= 6 { return .sadhak }
        return .seeker
    }
    
    public static func xpForLevel(_ level: Int) -> Int {
        level * 1000
    }
    
    public static func xpMultiplier(streakCount: Int) -> Double {
        if streakCount >= 30 { return 2.0 }
        if streakCount >= 14 { return 1.5 }
        if streakCount >= 7 { return 1.25 }
        if streakCount >= 3 { return 1.1 }
        return 1.0
    }
    
    public static func getContextualMotivation(
        streakCount: Int,
        level: Int,
        todayJapCount: Int,
        dailyGoal: Int
    ) -> String {
        if streakCount == 0 {
            return "आज नई शुरुआत करें! एक छोटा कदम बड़ी यात्रा की शुरुआत है।"
        }
        if streakCount >= 30 {
            return "\(streakCount) दिन! आप सच्चे तपस्वी हैं। आपकी साधना प्रेरणादायक है!"
        }
        if streakCount >= 7 {
            return "\(streakCount) दिनों से लगातार! अद्भुत! रुकना मत!"
        }
        
        let goalPercent = dailyGoal > 0 ? (Double(todayJapCount) / (Double(dailyGoal) * 108.0)) : 0.0
        if goalPercent >= 1.0 {
            return "आज का लक्ष्य पूरा! आप अद्भुत हैं! और जाप करें या ज्ञान पढ़ें।"
        }
        if goalPercent >= 0.5 {
            return "आधा लक्ष्य पूरा! बस थोड़ा और। हर जाप आपको करीब ला रहा है।"
        }
        
        let tier = detectLevel(userLevel: level)
        switch tier {
        case .seeker:
            return "साधना का सफर शुरू करें। छोटी शुरुआत ही बड़ी सफलता का आधार है।"
        case .sadhak:
            return "आपकी साधना गहरी हो रही है। नियमित अभ्यास से सिद्धि मिलती है।"
        case .tapasvi:
            return "तपस्वी, आपका तप अब फल दे रहा है। और ऊंचा उड़ें!"
        case .siddha:
            return "सिद्ध भक्त, आपकी साधना अनुपम है। अब दूसरों को मार्ग दिखाएं।"
        }
    }
    
    public static func checkNewAchievements(
        stats: UserStats,
        alreadyUnlocked: Set<String>,
        todayJapCount: Int = 0,
        ritualsCompleted: Int = 0
    ) -> [Achievement] {
        var newlyEarned: [Achievement] = []
        
        for achievement in Achievement.allAchievements {
            if alreadyUnlocked.contains(achievement.id) { continue }
            
            var earned = false
            switch achievement.condition {
            case "total_jap_count":
                earned = stats.totalJapCount >= achievement.targetValue
            case "streak_count":
                earned = stats.streakCount >= achievement.targetValue
            case "total_malas":
                earned = (stats.totalJapCount / 108) >= achievement.targetValue
            case "total_shlokas_read":
                earned = stats.totalShlokasRead >= achievement.targetValue
            case "level":
                earned = stats.level >= achievement.targetValue
            case "daily_jap_count":
                earned = todayJapCount >= achievement.targetValue
            case "rituals_completed":
                earned = ritualsCompleted >= achievement.targetValue
            default:
                break
            }
            
            if earned {
                newlyEarned.append(achievement)
            }
        }
        
        return newlyEarned
    }
    
    public static func contentDifficulty(userLevel: Int) -> Int {
        if userLevel >= 21 { return 3 }
        if userLevel >= 11 { return 2 }
        return 1
    }
    
    public static func levelTitle(level: SpiritualityLevel) -> String {
        switch level {
        case .seeker:
            return "साधक (Seeker)"
        case .sadhak:
            return "साधक (Practitioner)"
        case .tapasvi:
            return "तपस्वी (Ascetic)"
        case .siddha:
            return "सिद्ध (Enlightened)"
        }
    }
    
    public static func levelDescription(level: SpiritualityLevel) -> String {
        switch level {
        case .seeker:
            return "आप अपनी आध्यात्मिक यात्रा की शुरुआत में हैं। नियमित साधना से आप आगे बढ़ेंगे।"
        case .sadhak:
            return "आपकी साधना नियमित हो रही है। गहरे ज्ञान और कठिन अभ्यास के लिए तैयार हो रहे हैं।"
        case .tapasvi:
            return "आपका तप और समर्पण अद्भुत है। अब गहन आध्यात्मिक ज्ञान आपके लिए उपलब्ध है।"
        case .siddha:
            return "आप सिद्धि की ओर हैं। आपकी साधना दूसरों के लिए प्रेरणा है।"
        }
    }
    
    public static func suggestedDailyGoal(userLevel: Int) -> Int {
        if userLevel >= 31 { return 21 }
        if userLevel >= 16 { return 11 }
        if userLevel >= 6 { return 5 }
        return 1
    }
}
