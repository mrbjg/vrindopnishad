import SwiftUI

public struct HomeView: View {
    @State private var xp: Int = 3450
    @State private var streak: Int = 12
    @State private var userLevel: Int = 4
    
    @State private var dailyGyaan = DailyGyaan(
        id: "gyaan_1",
        title: "भगवद्गीता ज्ञान",
        content: "कर्मण्येवाधिकारस्ते मा फलेषु कदाचन।\nकर्म करो और फल की चिंता मत करो, क्योंकि केवल कर्म पर ही तुम्हारा वश है, फल पर नहीं।",
        mediaUrl: "https://images.unsplash.com/photo-1506126613408-eca07ce68773?auto=format&fit=crop&w=600&q=80",
        mediaType: "image",
        difficulty: 1,
        category: "Gita",
        createdAt: Date()
    )
    
    @State private var dailyMotivation = DailyMotivation(
        id: "mot_1",
        content: "विश्वास वह शक्ति है जिससे उजड़ी हुई दुनिया में भी प्रकाश किया जा सकता है।",
        source: "संत कबीर",
        minLevel: 1,
        maxLevel: 99,
        category: "general",
        language: "hi",
        createdAt: Date()
    )
    
    @State private var challenges = [
        DailyChallenge(
            id: "c1",
            title: "1 माला जप पूरा करें",
            description: nil,
            type: "naam_jap",
            targetValue: 108,
            xpReward: 100,
            minLevel: 1,
            date: nil,
            currentValue: 45,
            createdAt: Date(),
            isCompleted: false,
            completedAt: nil
        ),
        DailyChallenge(
            id: "c2",
            title: "5 मिनट ग्रंथ पढ़ें",
            description: nil,
            type: "reading",
            targetValue: 5,
            xpReward: 100,
            minLevel: 1,
            date: nil,
            currentValue: 3,
            createdAt: Date(),
            isCompleted: false,
            completedAt: nil
        )
    ]
    
    private var timeAwareGreeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour >= 4 && hour < 6 {
            return "सूर्योदय वंदन (शुभ प्रभात)"
        } else if hour >= 6 && hour < 12 {
            return "सुप्रभातम (शुभ प्रभात)"
        } else if hour >= 12 && hour < 16 {
            return "शुभ दोपहर"
        } else if hour >= 16 && hour < 20 {
            return "शुभ संध्या"
        } else {
            return "शुभ रात्रि"
        }
    }
    
    public var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 24) {
                Color.clear
                    .frame(height: 0)
                    .detectScroll()
                
                // MARK: - Welcome User Profile Bar
                HStack(spacing: 16) {
                    // Profile Image placeholder with glowing aura
                    ZStack {
                        Circle()
                            .fill(ThemeManager.shared.activeAccent.opacity(0.2))
                            .frame(width: 50, height: 50)
                            .evolvingAura(color: ThemeManager.shared.activeAccent, intensity: 1.0)
                        
                        Text("ॐ")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(ThemeManager.shared.activeAccent)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(timeAwareGreeting)
                            .font(PremiumFonts.sans(size: 14, weight: .semibold))
                            .foregroundColor(ThemeManager.shared.textSecondary)
                        
                        Text(SpiritualityEngine.levelTitle(level: SpiritualityEngine.detectLevel(userLevel: userLevel)))
                            .font(PremiumFonts.display(size: 18, weight: .bold))
                            .foregroundColor(ThemeManager.shared.textPrimary)
                    }
                    
                    Spacer()
                    
                    // Streak Badge
                    HStack(spacing: 6) {
                        Text("🔥")
                            .font(.system(size: 16))
                        Text("\(streak) दिन")
                            .font(PremiumFonts.sans(size: 13, weight: .black))
                            .foregroundColor(ThemeManager.shared.activeAccent)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .glassCard(borderRadius: 12)
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                // MARK: - Level Progress Bar
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("स्तर (Level) \(userLevel)")
                            .font(PremiumFonts.sans(size: 13, weight: .bold))
                            .foregroundColor(ThemeManager.shared.textPrimary)
                        
                        Spacer()
                        
                        let nextXP = SpiritualityEngine.xpForLevel(userLevel)
                        Text("\(xp) / \(nextXP) XP")
                            .font(PremiumFonts.sans(size: 11, weight: .medium))
                            .foregroundColor(ThemeManager.shared.textMuted)
                    }
                    
                    let nextXP = Double(SpiritualityEngine.xpForLevel(userLevel))
                    let progress = Double(xp) / nextXP
                    
                    LiquidProgressBar(value: progress)
                }
                .padding(.horizontal)
                
                // MARK: - Today's Daily Challenges
                VStack(alignment: .leading, spacing: 14) {
                    Text("आज की साधना (Daily Tasks)")
                        .font(PremiumFonts.sans(size: 15, weight: .black))
                        .tracking(1)
                        .foregroundColor(ThemeManager.shared.textPrimary)
                    
                    ForEach(challenges) { challenge in
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .stroke(ThemeManager.shared.borderColor, lineWidth: 3)
                                    .frame(width: 40, height: 40)
                                
                                Circle()
                                    .trim(from: 0.0, to: CGFloat(challenge.progressPercent))
                                    .stroke(ThemeManager.shared.activeAccent, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                                    .frame(width: 40, height: 40)
                                    .rotationEffect(Angle(degrees: -90))
                                
                                Text(challenge.typeIcon)
                                    .font(PremiumFonts.sans(size: 10, weight: .bold))
                                    .foregroundColor(ThemeManager.shared.textPrimary)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(challenge.title)
                                    .font(PremiumFonts.sans(size: 14, weight: .bold))
                                    .foregroundColor(challenge.isCompleted ? ThemeManager.shared.textMuted : ThemeManager.shared.textPrimary)
                                    .strikethrough(challenge.isCompleted, color: ThemeManager.shared.textMuted)
                                
                                Text("\(challenge.currentValue) / \(challenge.targetValue) (\(challenge.typeLabel))")
                                    .font(PremiumFonts.sans(size: 11, weight: .medium))
                                    .foregroundColor(ThemeManager.shared.textMuted)
                            }
                            
                            Spacer()
                            
                            if challenge.isCompleted {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(ThemeManager.shared.activeAccent)
                                    .font(.system(size: 18))
                            } else {
                                Text("+\(challenge.xpReward) XP")
                                    .font(PremiumFonts.sans(size: 12, weight: .heavy))
                                    .foregroundColor(ThemeManager.shared.activeAccent)
                            }
                        }
                        .padding()
                        .glassCard(borderRadius: 16)
                        .liquidDraggable(isCompleted: challenge.isCompleted) {
                            if let idx = challenges.firstIndex(where: { $0.id == challenge.id }) {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                    challenges[idx].currentValue = challenges[idx].targetValue
                                    challenges[idx].isCompleted = true
                                    AppHapticFeedback.heavyImpact()
                                }
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            AppHapticFeedback.mediumImpact()
                            if let idx = challenges.firstIndex(where: { $0.id == challenge.id }) {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                                    if challenges[idx].currentValue < challenges[idx].targetValue {
                                        challenges[idx].currentValue += (challenges[idx].type == "naam_jap" ? 10 : 1)
                                        if challenges[idx].currentValue >= challenges[idx].targetValue {
                                            challenges[idx].currentValue = challenges[idx].targetValue
                                            challenges[idx].isCompleted = true
                                            AppHapticFeedback.heavyImpact()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                // MARK: - Daily Gyaan Wisdom Card
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("दैनिक ज्ञान (Wisdom of Day)")
                            .font(PremiumFonts.sans(size: 15, weight: .black))
                            .tracking(1)
                            .foregroundColor(ThemeManager.shared.textPrimary)
                        
                        Spacer()
                        
                        PremiumUI.categoryBadge(dailyGyaan.category ?? "General")
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        if let mediaUrl = dailyGyaan.mediaUrl, !ThemeManager.shared.uiLiteEnabled {
                            AsyncImage(url: URL(string: mediaUrl)) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(height: 160)
                                        .clipped()
                                        .cornerRadius(16)
                                default:
                                    EmptyView()
                                }
                            }
                        }
                        
                        Text(dailyGyaan.title)
                            .font(PremiumFonts.display(size: 20, weight: .bold))
                            .foregroundColor(ThemeManager.shared.textPrimary)
                        
                        Text(dailyGyaan.content)
                            .font(PremiumFonts.hindiAware(size: 14, text: dailyGyaan.content))
                            .foregroundColor(ThemeManager.shared.textSecondary)
                            .lineSpacing(6)
                    }
                    .padding()
                    .glassCard(borderRadius: 24)
                }
                .padding(.horizontal)
                
                // MARK: - Daily Motivation Quote Card
                VStack(alignment: .leading, spacing: 12) {
                    Text("सुविचार (Daily Quote)")
                        .font(PremiumFonts.sans(size: 15, weight: .black))
                        .tracking(1)
                        .foregroundColor(ThemeManager.shared.textPrimary)
                    
                    ZStack {
                        if !ThemeManager.shared.uiLiteEnabled {
                            // Large stylized quotes watermark
                            Text("“")
                                .font(.system(size: 140, weight: .black, design: .serif))
                                .foregroundColor(ThemeManager.shared.activeAccent.opacity(0.08))
                                .offset(x: -120, y: -45)
                        }
                        
                        VStack(spacing: 14) {
                            Text(dailyMotivation.content)
                                .font(PremiumFonts.hindiAware(size: 15, text: dailyMotivation.content, weight: .medium, isSacred: true))
                                .multilineTextAlignment(.center)
                                .foregroundColor(ThemeManager.shared.textPrimary)
                                .lineSpacing(6)
                                .padding(.horizontal, 10)
                            
                            if let source = dailyMotivation.source {
                                Text("— \(source)")
                                    .font(PremiumFonts.sans(size: 13, weight: .semibold))
                                    .foregroundColor(ThemeManager.shared.activeAccent)
                            }
                        }
                        .padding(.vertical, 24)
                        .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity)
                    .glassCard(borderRadius: 20)
                }
                .padding(.horizontal)
                .padding(.bottom, 100) // Space for bottom tab bar and player
            }
        }
        .coordinateSpace(name: "scroll")
        .background(PremiumUI.masterBackground())
    }
}
