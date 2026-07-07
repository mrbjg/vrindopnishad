import SwiftUI

// MARK: - Color Hex Extension
extension Color {
    public init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255.0,
            green: Double((hex >> 8) & 0xff) / 255.0,
            blue: Double(hex & 0xff) / 255.0,
            opacity: alpha
        )
    }
}

// MARK: - App Color Themes
public enum AppColorTheme: Int, CaseIterable, Codable {
    case nebulaBlue = 0
    case saffronSacred
    case lotusRose
    case emeraldDivine
    case amethystMystic
    case celestialGold
    case oceanTeal
    case midnightIndigo
}

public struct AppColorPalette {
    public let name: String
    public let nameHi: String
    public let nameSa: String
    public let emoji: String
    public let accent: Color
    public let accentLight: Color
    public let accentDark: Color
    public let glow: Color
    public let gradient: [Color]
}

public struct AppColorThemes {
    public static let palettes: [AppColorTheme: AppColorPalette] = [
        .nebulaBlue: AppColorPalette(
            name: "Nebula Blue", nameHi: "नेबुला नीला", nameSa: "नीहारिका नीलम्", emoji: "🌌",
            accent: Color(hex: 0xFF256AF4), accentLight: Color(hex: 0xFF4D8BFF), accentDark: Color(hex: 0xFF1A4FBF),
            glow: Color(hex: 0xFF256AF4), gradient: [Color(hex: 0xFF256AF4), Color(hex: 0xFF0A0A1A)]
        ),
        .saffronSacred: AppColorPalette(
            name: "Sacred Saffron", nameHi: "पवित्र केसरिया", nameSa: "केसरवर्णम्", emoji: "🪷",
            accent: Color(hex: 0xFFF2A60D), accentLight: Color(hex: 0xFFFFBF3D), accentDark: Color(hex: 0xFFD68A00),
            glow: Color(hex: 0xFFF2A60D), gradient: [Color(hex: 0xFFF2A60D), Color(hex: 0xFFD68A00)]
        ),
        .lotusRose: AppColorPalette(
            name: "Lotus Rose", nameHi: "कमल गुलाबी", nameSa: "पद्मरागम्", emoji: "🌸",
            accent: Color(hex: 0xFFE8437F), accentLight: Color(hex: 0xFFFF6B9D), accentDark: Color(hex: 0xFFC42D66),
            glow: Color(hex: 0xFFE8437F), gradient: [Color(hex: 0xFFE8437F), Color(hex: 0xFFBE185D)]
        ),
        .emeraldDivine: AppColorPalette(
            name: "Divine Emerald", nameHi: "दिव्य पन्ना", nameSa: "मरकतम्", emoji: "🍀",
            accent: Color(hex: 0xFF10B981), accentLight: Color(hex: 0xFF34D399), accentDark: Color(hex: 0xFF059669),
            glow: Color(hex: 0xFF10B981), gradient: [Color(hex: 0xFF10B981), Color(hex: 0xFF047857)]
        ),
        .amethystMystic: AppColorPalette(
            name: "Mystic Amethyst", nameHi: "रहस्यमय बैंगनी", nameSa: "अमृतवर्णम्", emoji: "🔮",
            accent: Color(hex: 0xFF8B5CF6), accentLight: Color(hex: 0xFFA78BFA), accentDark: Color(hex: 0xFF7C3AED),
            glow: Color(hex: 0xFF8B5CF6), gradient: [Color(hex: 0xFF8B5CF6), Color(hex: 0xFF6D28D9)]
        ),
        .celestialGold: AppColorPalette(
            name: "Celestial Gold", nameHi: "दिव्य स्वर्ण", nameSa: "स्वर्णवर्णम्", emoji: "👑",
            accent: Color(hex: 0xFFD4A017), accentLight: Color(hex: 0xFFEABF3F), accentDark: Color(hex: 0xFFB8860B),
            glow: Color(hex: 0xFFD4A017), gradient: [Color(hex: 0xFFD4A017), Color(hex: 0xFFB8860B)]
        ),
        .oceanTeal: AppColorPalette(
            name: "Ocean Teal", nameHi: "सागर नीला", nameSa: "सागरनीलम्", emoji: "🌊",
            accent: Color(hex: 0xFF0891B2), accentLight: Color(hex: 0xFF22D3EE), accentDark: Color(hex: 0xFF0E7490),
            glow: Color(hex: 0xFF0891B2), gradient: [Color(hex: 0xFF0891B2), Color(hex: 0xFF164E63)]
        ),
        .midnightIndigo: AppColorPalette(
            name: "Midnight Indigo", nameHi: "मध्यरात्रि जामुनी", nameSa: "नीलमणिः", emoji: "🌙",
            accent: Color(hex: 0xFF6366F1), accentLight: Color(hex: 0xFF818CF8), accentDark: Color(hex: 0xFF4F46E5),
            glow: Color(hex: 0xFF6366F1), gradient: [Color(hex: 0xFF6366F1), Color(hex: 0xFF4338CA)]
        )
    ]

    public static func getPalette(_ theme: AppColorTheme) -> AppColorPalette {
        palettes[theme] ?? palettes[.nebulaBlue]!
    }
}

// MARK: - App Mood Themes
public enum AppMoodTheme: Int, CaseIterable, Codable {
    case sereneDawn = 0
    case midnightVoid
    case cloudyCalm
    case shinyBloom
    case coldMist
    case rainyPeace
    case monsoonGreen
    case forestHaven
    case waterfallBlue
    case mountainPeak
    case cherryBlossom
}

public struct AppMoodPalette {
    public let name: String
    public let nameHi: String
    public let emoji: String
    public let isDark: Bool
    public let scaffoldBg: Color
    public let surfaceColor: Color
    public let cardColor: Color
    public let textPrimary: Color
    public let textSecondary: Color
    public let textMuted: Color
    public let borderColor: Color
    public let backgroundGradient: [Color]
    public let defaultAccent: AppColorTheme
}

public struct AppMoodThemes {
    public static let palettes: [AppMoodTheme: AppMoodPalette] = [
        .sereneDawn: AppMoodPalette(
            name: "Serene Dawn", nameHi: "प्रभात शांति", emoji: "🌅", isDark: false,
            scaffoldBg: Color(hex: 0xFFFFFDF5), surfaceColor: Color(hex: 0xFFFFF9E0), cardColor: Color(hex: 0xFFFFFFFF),
            textPrimary: Color(hex: 0xFF2D2D2D), textSecondary: Color(hex: 0xFF5D5D5D), textMuted: Color(hex: 0xFF7A7062),
            borderColor: Color(hex: 0xFFE8E0D0), backgroundGradient: [Color(hex: 0xFFFFFDF5), Color(hex: 0xFFFFF0D0), Color(hex: 0xFFFFFDF5)],
            defaultAccent: .saffronSacred
        ),
        .midnightVoid: AppMoodPalette(
            name: "Midnight Void", nameHi: "मध्यरात्रि", emoji: "🌑", isDark: true,
            scaffoldBg: Color(hex: 0xFF050512), surfaceColor: Color(hex: 0xFF0C0C22), cardColor: Color(hex: 0xFF0A0A1C),
            textPrimary: Color(hex: 0xFFF5F5F7), textSecondary: Color(hex: 0xFFB4B4D8), textMuted: Color(hex: 0xFF7D7DA3),
            borderColor: Color(hex: 0xFF1D1D3A), backgroundGradient: [Color(hex: 0xFF050512), Color(hex: 0xFF0F0F35), Color(hex: 0xFF050512)],
            defaultAccent: .nebulaBlue
        ),
        .cloudyCalm: AppMoodPalette(
            name: "Cloudy Calm", nameHi: "मेघ शांति", emoji: "☁️", isDark: false,
            scaffoldBg: Color(hex: 0xFFF0F2F5), surfaceColor: Color(hex: 0xFFE8ECF0), cardColor: Color(hex: 0xFFFFFFFF),
            textPrimary: Color(hex: 0xFF2D2D2D), textSecondary: Color(hex: 0xFF5D5D5D), textMuted: Color(hex: 0xFF707885),
            borderColor: Color(hex: 0xFFD8DDE4), backgroundGradient: [Color(hex: 0xFFF0F2F5), Color(hex: 0xFFE4E8EE), Color(hex: 0xFFF0F2F5)],
            defaultAccent: .oceanTeal
        ),
        .shinyBloom: AppMoodPalette(
            name: "Shiny Bloom", nameHi: "धूप प्रकाश", emoji: "☀️", isDark: false,
            scaffoldBg: Color(hex: 0xFFFFF8E8), surfaceColor: Color(hex: 0xFFFFEFC0), cardColor: Color(hex: 0xFFFFFDF5),
            textPrimary: Color(hex: 0xFF2D2D2D), textSecondary: Color(hex: 0xFF5D5D5D), textMuted: Color(hex: 0xFF8A7E62),
            borderColor: Color(hex: 0xFFE8D8B0), backgroundGradient: [Color(hex: 0xFFFFF8E8), Color(hex: 0xFFFFEDCC), Color(hex: 0xFFFFF8E8)],
            defaultAccent: .celestialGold
        ),
        .forestHaven: AppMoodPalette(
            name: "Forest Haven", nameHi: "वन शांति", emoji: "🌲", isDark: false,
            scaffoldBg: Color(hex: 0xFFF5F8F0), surfaceColor: Color(hex: 0xFFE8F0E0), cardColor: Color(hex: 0xFFFFFFFF),
            textPrimary: Color(hex: 0xFF2D2D2D), textSecondary: Color(hex: 0xFF5D5D5D), textMuted: Color(hex: 0xFF707D65),
            borderColor: Color(hex: 0xFFD0E0C8), backgroundGradient: [Color(hex: 0xFFF5F8F0), Color(hex: 0xFFEAF2DD), Color(hex: 0xFFF5F8F0)],
            defaultAccent: .emeraldDivine
        ),
        .waterfallBlue: AppMoodPalette(
            name: "Waterfall Blue", nameHi: "जलप्रपात", emoji: "💧", isDark: false,
            scaffoldBg: Color(hex: 0xFFF0F8FF), surfaceColor: Color(hex: 0xFFE0F0FF), cardColor: Color(hex: 0xFFFFFFFF),
            textPrimary: Color(hex: 0xFF2D2D2D), textSecondary: Color(hex: 0xFF5D5D5D), textMuted: Color(hex: 0xFF6B7A8C),
            borderColor: Color(hex: 0xFFCCE0F0), backgroundGradient: [Color(hex: 0xFFF0F8FF), Color(hex: 0xFFE0EFFF), Color(hex: 0xFFF0F8FF)],
            defaultAccent: .oceanTeal
        ),
        .coldMist: AppMoodPalette(
            name: "Cold Mist", nameHi: "शीत कुहासा", emoji: "❄️", isDark: true,
            scaffoldBg: Color(hex: 0xFF060F1E), surfaceColor: Color(hex: 0xFF0D1B2E), cardColor: Color(hex: 0xFF0C192A),
            textPrimary: Color(hex: 0xFFF5F5F7), textSecondary: Color(hex: 0xFFAEC6E4), textMuted: Color(hex: 0xFF748DAE),
            borderColor: Color(hex: 0xFF1D2F47), backgroundGradient: [Color(hex: 0xFF060F1E), Color(hex: 0xFF0E233E), Color(hex: 0xFF060F1E)],
            defaultAccent: .oceanTeal
        ),
        .rainyPeace: AppMoodPalette(
            name: "Rainy Peace", nameHi: "वर्षा शांति", emoji: "🌧️", isDark: true,
            scaffoldBg: Color(hex: 0xFF0B1017), surfaceColor: Color(hex: 0xFF151D2A), cardColor: Color(hex: 0xFF111722),
            textPrimary: Color(hex: 0xFFF5F5F7), textSecondary: Color(hex: 0xFF9CB1CB), textMuted: Color(hex: 0xFF6B7F97),
            borderColor: Color(hex: 0xFF202C3D), backgroundGradient: [Color(hex: 0xFF0B1017), Color(hex: 0xFF18283B), Color(hex: 0xFF0B1017)],
            defaultAccent: .oceanTeal
        ),
        .monsoonGreen: AppMoodPalette(
            name: "Monsoon Green", nameHi: "सावन हरियाली", emoji: "🌿", isDark: true,
            scaffoldBg: Color(hex: 0xFF04100C), surfaceColor: Color(hex: 0xFF09201A), cardColor: Color(hex: 0xFF081C16),
            textPrimary: Color(hex: 0xFFF5F5F7), textSecondary: Color(hex: 0xFF92BBA6), textMuted: Color(hex: 0xFF638A76),
            borderColor: Color(hex: 0xFF123227), backgroundGradient: [Color(hex: 0xFF04100C), Color(hex: 0xFF0D2D23), Color(hex: 0xFF04100C)],
            defaultAccent: .emeraldDivine
        ),
        .mountainPeak: AppMoodPalette(
            name: "Mountain Peak", nameHi: "पर्वत शिखर", emoji: "🏔️", isDark: true,
            scaffoldBg: Color(hex: 0xFF090712), surfaceColor: Color(hex: 0xFF141026), cardColor: Color(hex: 0xFF100C1F),
            textPrimary: Color(hex: 0xFFF5F5F7), textSecondary: Color(hex: 0xFFAAA5C8), textMuted: Color(hex: 0xFF736F95),
            borderColor: Color(hex: 0xFF231C3C), backgroundGradient: [Color(hex: 0xFF090712), Color(hex: 0xFF1C133A), Color(hex: 0xFF090712)],
            defaultAccent: .amethystMystic
        ),
        .cherryBlossom: AppMoodPalette(
            name: "Cherry Blossom", nameHi: "चेरी ब्लॉसम", emoji: "🌸", isDark: false,
            scaffoldBg: Color(hex: 0xFFFFF0F5), surfaceColor: Color(hex: 0xFFFFE4E1), cardColor: Color(hex: 0xFFFFFFFF),
            textPrimary: Color(hex: 0xFF2D2D2D), textSecondary: Color(hex: 0xFF5D5D5D), textMuted: Color(hex: 0xFF8A6B70),
            borderColor: Color(hex: 0xFFFCD0D7), backgroundGradient: [Color(hex: 0xFFFFF0F5), Color(hex: 0xFFFFE4E1), Color(hex: 0xFFFFF0F5)],
            defaultAccent: .lotusRose
        )
    ]

    public static func getPalette(_ mood: AppMoodTheme) -> AppMoodPalette {
        palettes[mood] ?? palettes[.sereneDawn]!
    }
}

// MARK: - ThemeManager (Observable State)
@Observable
public final class ThemeManager {
    public static let shared = ThemeManager()

    public var currentMood: AppMoodTheme {
        didSet {
            UserDefaults.standard.set(currentMood.rawValue, forKey: "app_mood_theme")
            // Automatically pair with the mood's default accent
            let palette = AppMoodThemes.getPalette(currentMood)
            currentColorTheme = palette.defaultAccent
        }
    }

    public var currentColorTheme: AppColorTheme {
        didSet {
            UserDefaults.standard.set(currentColorTheme.rawValue, forKey: "app_color_theme")
        }
    }

    public var trueDarkEnabled: Bool {
        didSet {
            UserDefaults.standard.set(trueDarkEnabled, forKey: "true_dark_enabled")
        }
    }

    public var uiLiteEnabled: Bool {
        didSet {
            UserDefaults.standard.set(uiLiteEnabled, forKey: "ui_lite_enabled")
        }
    }

    public var hapticEnabled: Bool {
        didSet {
            UserDefaults.standard.set(hapticEnabled, forKey: "haptic_enabled")
        }
    }
    
    public var isTabBarExpanded: Bool = true

    public func setTabBarExpanded(_ expanded: Bool) {
        // Run on MainActor to ensure safe UI updates
        Task { @MainActor in
            guard self.isTabBarExpanded != expanded else { return }
            withAnimation(.spring(response: 0.38, dampingFraction: 0.82)) {
                self.isTabBarExpanded = expanded
            }
        }
    }

    private init() {
        self.currentMood = AppMoodTheme(rawValue: UserDefaults.standard.integer(forKey: "app_mood_theme")) ?? .sereneDawn
        self.currentColorTheme = AppColorTheme(rawValue: UserDefaults.standard.integer(forKey: "app_color_theme")) ?? .saffronSacred
        self.trueDarkEnabled = UserDefaults.standard.bool(forKey: "true_dark_enabled")
        self.uiLiteEnabled = UserDefaults.standard.bool(forKey: "ui_lite_enabled")
        self.hapticEnabled = UserDefaults.standard.object(forKey: "haptic_enabled") as? Bool ?? true
    }

    // Active Palettes
    public var activeMoodPalette: AppMoodPalette {
        AppMoodThemes.getPalette(currentMood)
    }

    public var activeColorPalette: AppColorPalette {
        AppColorThemes.getPalette(currentColorTheme)
    }

    // Computed Theme Colors
    public var scaffoldBg: Color {
        activeMoodPalette.scaffoldBg
    }

    public var surfaceColor: Color {
        activeMoodPalette.surfaceColor
    }

    public var cardColor: Color {
        activeMoodPalette.cardColor
    }

    public var textPrimary: Color {
        activeMoodPalette.textPrimary
    }

    public var textSecondary: Color {
        activeMoodPalette.textSecondary
    }

    public var textMuted: Color {
        activeMoodPalette.textMuted
    }

    public var borderColor: Color {
        activeMoodPalette.borderColor
    }

    public var backgroundGradient: [Color] {
        activeMoodPalette.backgroundGradient
    }

    public var activeAccent: Color {
        activeColorPalette.accent
    }

    public var activeAccentLight: Color {
        activeColorPalette.accentLight
    }

    public var activeAccentDark: Color {
        activeColorPalette.accentDark
    }

    public var activeGlow: Color {
        activeColorPalette.glow
    }

    public var activeGradient: [Color] {
        activeColorPalette.gradient
    }
}

// MARK: - Typography & Fonts
public struct PremiumFonts {
    public static func display(size: CGFloat, weight: Font.Weight = .bold) -> Font {
        // Fallback to native serif (Georgia / Lora style) for sacred titles
        .system(size: size, weight: weight, design: .serif)
    }

    public static func sans(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        // Poppins style sans-serif
        .system(size: size, weight: weight, design: .default)
    }

    public static func hindiAware(size: CGFloat, text: String, weight: Font.Weight = .regular, isSacred: Bool = false) -> Font {
        let hasHindi = text.range(of: "\\p{Devanagari}", options: .regularExpression) != nil
        let adjustedSize = hasHindi ? (size + 2) : size
        
        if isSacred {
            return .system(size: adjustedSize, weight: weight, design: .serif)
        } else {
            return .system(size: adjustedSize, weight: weight, design: .default)
        }
    }
}
