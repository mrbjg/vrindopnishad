import SwiftUI

public struct SacredCalendarView: View {
    @State private var events = [
        SacredEvent(id: "ev_1", title: "देवशयनी एकादशी व्रत", description: "आषाढ़ शुक्ल पक्ष की एकादशी तिथि। इस दिन से चातुर्मास व्रत प्रारंभ होता है।", date: Calendar.current.date(byAdding: .day, value: 1, to: Date())!, type: "ekadashi", isRecurring: true, createdAt: Date()),
        SacredEvent(id: "ev_2", title: "गुरु पूर्णिमा उत्सव", description: "गुरु पूजा और व्यास पूजा का महापर्व। अपने गुरुजनों के प्रति आभार व्यक्त करने का दिन।", date: Calendar.current.date(byAdding: .day, value: 4, to: Date())!, type: "purnima", isRecurring: true, createdAt: Date()),
        SacredEvent(id: "ev_3", title: "श्रावण सोमवार व्रत", description: "श्रावण मास का प्रथम सोमवार व्रत। भगवान शिव की विशेष पूजा अर्चना।", date: Calendar.current.date(byAdding: .day, value: 7, to: Date())!, type: "vrat", isRecurring: false, createdAt: Date())
    ]
    
    public var body: some View {
        ZStack {
            PremiumUI.masterBackground()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("पावन कैलेंडर")
                        .font(PremiumFonts.display(size: 24, weight: .bold))
                        .foregroundColor(ThemeManager.shared.textPrimary)
                    
                    Spacer()
                    
                    Text("संवत २०८३")
                        .font(PremiumFonts.sans(size: 13, weight: .bold))
                        .foregroundColor(ThemeManager.shared.activeAccent)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .glassCard(borderRadius: 12)
                }
                .padding()
                
                // Calendar List
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(events) { event in
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    // Colored dot based on event type
                                    Circle()
                                        .fill(eventColor(event.type))
                                        .frame(width: 8, height: 8)
                                    
                                    Text(event.title)
                                        .font(PremiumFonts.sans(size: 16, weight: .bold))
                                        .foregroundColor(ThemeManager.shared.textPrimary)
                                    
                                    Spacer()
                                    
                                    PremiumUI.resonanceBadge(event.typeLabel)
                                }
                                
                                if let desc = event.description {
                                    Text(desc)
                                        .font(PremiumFonts.sans(size: 13))
                                        .foregroundColor(ThemeManager.shared.textSecondary)
                                        .lineLimit(2)
                                        .lineSpacing(4)
                                }
                                
                                HStack {
                                    Image(systemName: "calendar")
                                        .font(.system(size: 12))
                                        .foregroundColor(ThemeManager.shared.textMuted)
                                    
                                    Text(formatDate(event.date))
                                        .font(PremiumFonts.sans(size: 11, weight: .semibold))
                                        .foregroundColor(ThemeManager.shared.textMuted)
                                    
                                    Spacer()
                                    
                                    if event.isRecurring {
                                        HStack(spacing: 4) {
                                            Image(systemName: "arrow.3.trianglepath")
                                                .font(.system(size: 10))
                                            Text("वार्षिक")
                                                .font(PremiumFonts.sans(size: 10, weight: .semibold))
                                        }
                                        .foregroundColor(ThemeManager.shared.activeAccent)
                                    }
                                }
                                .padding(.top, 4)
                            }
                            .padding()
                            .glassCard(borderRadius: 20)
                            .glassTint(eventColor(event.type), intensity: 0.08, borderRadius: 20)
                        }
                    }
                    .padding()
                }
            }
        }
    }
    
    private func eventColor(_ type: String) -> Color {
        switch type {
        case "ekadashi": return Color(hex: 0xFFF2A60D) // Saffron
        case "purnima": return Color(hex: 0xFF256AF4) // Blue
        case "vrat": return Color(hex: 0xFF10B981) // Green
        default: return ThemeManager.shared.textMuted
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM"
        formatter.locale = Locale(identifier: "hi_IN")
        return formatter.string(from: date)
    }
}
