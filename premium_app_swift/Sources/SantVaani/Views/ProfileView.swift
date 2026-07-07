import SwiftUI

public struct ProfileView: View {
    @State private var themeManager = ThemeManager.shared
    @State private var dailyGoal = 11
    
    public var body: some View {
        ZStack {
            PremiumUI.masterBackground()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    Color.clear
                        .frame(height: 0)
                        .detectScroll()
                    
                    // MARK: - Header Profile Info
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(themeManager.activeAccent.opacity(0.15))
                                .frame(width: 80, height: 80)
                                .evolvingAura(color: themeManager.activeAccent, intensity: 1.2)
                            
                            Text("सा")
                                .font(PremiumFonts.display(size: 32, weight: .bold))
                                .foregroundColor(themeManager.activeAccent)
                        }
                        
                        Text("साधक (Seeker)")
                            .font(PremiumFonts.display(size: 20, weight: .bold))
                            .foregroundColor(themeManager.textPrimary)
                        
                        Text("सदा साधना में लीन रहें")
                            .font(PremiumFonts.sans(size: 13))
                            .foregroundColor(themeManager.textMuted)
                    }
                    .padding(.top, 20)
                    
                    // MARK: - Level Stats
                    HStack(spacing: 20) {
                        VStack(spacing: 4) {
                            Text("Level 4")
                                .font(PremiumFonts.sans(size: 15, weight: .bold))
                                .foregroundColor(themeManager.textPrimary)
                            Text("स्तर")
                                .font(PremiumFonts.sans(size: 11))
                                .foregroundColor(themeManager.textMuted)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .glassCard(borderRadius: 16)
                        
                        VStack(spacing: 4) {
                            Text("12 Days")
                                .font(PremiumFonts.sans(size: 15, weight: .bold))
                                .foregroundColor(themeManager.textPrimary)
                            Text("दैनिक लकीर")
                                .font(PremiumFonts.sans(size: 11))
                                .foregroundColor(themeManager.textMuted)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .glassCard(borderRadius: 16)
                    }
                    .padding(.horizontal)
                    
                    // MARK: - Customization: Moods
                    VStack(alignment: .leading, spacing: 12) {
                        Text("वातावरण (Mood Atmosphere)")
                            .font(PremiumFonts.sans(size: 14, weight: .bold))
                            .foregroundColor(themeManager.textPrimary)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(AppMoodTheme.allCases, id: \.self) { mood in
                                    let palette = AppMoodThemes.getPalette(mood)
                                    Button(action: {
                                        AppHapticFeedback.mediumImpact()
                                        withAnimation {
                                            themeManager.currentMood = mood
                                        }
                                    }) {
                                        VStack(spacing: 6) {
                                            Text(palette.emoji)
                                                .font(.system(size: 24))
                                            Text(palette.nameHi)
                                                .font(PremiumFonts.sans(size: 11, weight: .bold))
                                        }
                                        .frame(width: 80, height: 75)
                                        .foregroundColor(themeManager.currentMood == mood ? .white : themeManager.textPrimary)
                                        .background(themeManager.currentMood == mood ? themeManager.activeAccent : themeManager.cardColor)
                                        .cornerRadius(16)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(themeManager.currentMood == mood ? Color.clear : themeManager.borderColor, lineWidth: 1)
                                        )
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // MARK: - Customization: Color Themes
                    VStack(alignment: .leading, spacing: 12) {
                        Text("थीम रंग (Theme Accent)")
                            .font(PremiumFonts.sans(size: 14, weight: .bold))
                            .foregroundColor(themeManager.textPrimary)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(AppColorTheme.allCases, id: \.self) { theme in
                                    let palette = AppColorThemes.getPalette(theme)
                                    Button(action: {
                                        AppHapticFeedback.mediumImpact()
                                        withAnimation {
                                            themeManager.currentColorTheme = theme
                                        }
                                    }) {
                                        Circle()
                                            .fill(palette.accent)
                                            .frame(width: 44, height: 44)
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.white, lineWidth: themeManager.currentColorTheme == theme ? 3 : 0)
                                            )
                                            .shadow(color: palette.glow.opacity(0.3), radius: 6, x: 0, y: 3)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // MARK: - System Options
                    VStack(alignment: .leading, spacing: 4) {
                        Text("सेटअप विकल्प (System Settings)")
                            .font(PremiumFonts.sans(size: 14, weight: .bold))
                            .foregroundColor(themeManager.textPrimary)
                            .padding(.horizontal)
                            .padding(.bottom, 6)
                        
                        VStack(spacing: 0) {
                            // Mala Goal Stepper
                            HStack {
                                Text("दैनिक माला लक्ष्य (Daily Mala Goal)")
                                    .font(PremiumFonts.sans(size: 14))
                                    .foregroundColor(themeManager.textPrimary)
                                Spacer()
                                Stepper("\(dailyGoal) माला", value: $dailyGoal, in: 1...108) { _ in
                                    AppHapticFeedback.lightImpact()
                                }
                                .font(PremiumFonts.sans(size: 14, weight: .bold))
                            }
                            .padding()
                            
                            Divider()
                                .padding(.horizontal)
                            
                            // Haptic Toggle
                            Toggle(isOn: $themeManager.hapticEnabled) {
                                Text("स्पर्श प्रतिक्रिया (Haptic Feedback)")
                                    .font(PremiumFonts.sans(size: 14))
                                    .foregroundColor(themeManager.textPrimary)
                            }
                            .padding()
                            
                            Divider()
                                .padding(.horizontal)
                            
                            // UI Lite Toggle (Low Performance Mode)
                            Toggle(isOn: $themeManager.uiLiteEnabled) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("कम प्रदर्शन मोड (UI Lite Mode)")
                                        .font(PremiumFonts.sans(size: 14))
                                        .foregroundColor(themeManager.textPrimary)
                                    Text("कमजोर फोन के लिए एनिमेशन कम करें")
                                        .font(PremiumFonts.sans(size: 11))
                                        .foregroundColor(themeManager.textMuted)
                                }
                            }
                            .padding()
                        }
                        .glassCard(borderRadius: 24)
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                        .frame(height: 100)
                }
            }
            .coordinateSpace(name: "scroll")
        }
    }
}
