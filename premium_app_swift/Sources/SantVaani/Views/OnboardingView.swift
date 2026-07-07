import SwiftUI

struct OnboardingPage: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let emoji: String
}

public struct OnboardingView: View {
    @State private var currentPage = 0
    let onComplete: () -> Void
    
    let pages = [
        OnboardingPage(
            title: "नाम जप स्मरण",
            subtitle: "अपने मन्त्रों और नाम स्मरण को ट्रैक करने के लिए डिजिटल माला काउंटर का उपयोग करें।",
            emoji: "📿"
        ),
        OnboardingPage(
            title: "आध्यात्मिक पुस्तकालय",
            subtitle: "भजन, श्लोक, तिय और पावन ग्रंथों का वृहद संग्रह सुनें और पढ़ें।",
            emoji: "📖"
        ),
        OnboardingPage(
            title: "साधना डायरी",
            subtitle: "दैनिक जीवन के अपने आध्यात्मिक विचारों और अनुभवों को सुरक्षित रूप से संकलित करें।",
            emoji: "🪶"
        )
    ]
    
    public var body: some View {
        ZStack {
            PremiumUI.masterBackground()
            
            VStack {
                Spacer()
                
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        VStack(spacing: 24) {
                            Text(pages[index].emoji)
                                .font(.system(size: 80))
                                .evolvingAura(color: ThemeManager.shared.activeAccent, intensity: 1.0)
                                .padding(.bottom, 20)
                            
                            Text(pages[index].title)
                                .font(PremiumFonts.display(size: 26, weight: .bold))
                                .foregroundColor(ThemeManager.shared.textPrimary)
                            
                            Text(pages[index].subtitle)
                                .font(PremiumFonts.sans(size: 15))
                                .foregroundColor(ThemeManager.shared.textSecondary)
                                .multilineTextAlignment(.center)
                                .lineSpacing(6)
                                .padding(.horizontal, 32)
                        }
                        .tag(index)
                    }
                }
                #if os(iOS)
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                #endif
                .frame(height: 400)
                
                Spacer()
                
                // Page Indicator and Completion Button
                VStack(spacing: 16) {
                    if currentPage == pages.count - 1 {
                        Button(action: {
                            AppHapticFeedback.heavyImpact()
                            onComplete()
                        }) {
                            Text("साधना शुरू करें")
                                .font(PremiumFonts.sans(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(ThemeManager.shared.activeAccent)
                                .cornerRadius(16)
                                .shadow(color: ThemeManager.shared.activeAccent.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .padding(.horizontal, 24)
                    } else {
                        Button(action: {
                            AppHapticFeedback.lightImpact()
                            withAnimation {
                                currentPage += 1
                            }
                        }) {
                            Text("आगे बढ़ें")
                                .font(PremiumFonts.sans(size: 15, weight: .bold))
                                .foregroundColor(ThemeManager.shared.textPrimary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .glassCard(borderRadius: 16)
                        }
                        .padding(.horizontal, 24)
                    }
                    
                    Button("छोड़ें (Skip)") {
                        AppHapticFeedback.mediumImpact()
                        onComplete()
                    }
                    .font(PremiumFonts.sans(size: 13, weight: .medium))
                    .foregroundColor(ThemeManager.shared.textMuted)
                }
                .padding(.bottom, 40)
            }
        }
    }
}
