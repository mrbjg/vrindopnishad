import SwiftUI

public struct LibraryView: View {
    @State private var searchQuery: String = ""
    @State private var selectedCategory: String = "All"
    
    // Mock Database for SwiftData demonstration
    @State private var contentList = [
        SacredContent(
            id: "sc_1",
            title: "राधा गोविंद गीत",
            category: "Bhajan",
            sanskritText: "राधे राधे गोविंद गोविंद राधे।\nगोपाल गोपाल राधे राधे।",
            translation: "Chant the holy names of Radha, Govinda, and Gopala.",
            hindiMeaning: "राधा और कृष्ण के पावन नामों का कीर्तन करो।",
            commentary: "A beautiful traditional kirtan chanting the divine names.",
            imageUrl: "https://images.unsplash.com/photo-1615412727883-f8a6797f883a?auto=format&fit=crop&w=500&q=80",
            audioUrl: "https://actions.google.com/sounds/v1/ambiences/river_flowing.ogg",
            author: "पारंपरिक"
        ),
        SacredContent(
            id: "sc_2",
            title: "हरे कृष्ण महामंत्र",
            category: "Mantra",
            sanskritText: "हरे कृष्ण हरे कृष्ण कृष्ण कृष्ण हरे हरे।\nहरे राम हरे राम राम राम हरे हरे।",
            translation: "The Great Mantra for deliverance in Kali Yuga.",
            hindiMeaning: "यह कलियुग में कल्याण करने वाला परम पावन महामंत्र है।",
            commentary: "Chanting this mantra cleanses the mirror of the mind.",
            imageUrl: "https://images.unsplash.com/photo-1520262454112-9fe481d36ec3?auto=format&fit=crop&w=500&q=80",
            audioUrl: "https://actions.google.com/sounds/v1/ambiences/wind_constant.ogg",
            author: "वेद व्यास"
        ),
        SacredContent(
            id: "sc_3",
            title: "दामोदराष्टकम्",
            category: "Shloka",
            sanskritText: "नमामीश्वरं सच्चिदानन्दरूपं\nलसत्कुण्डलं गोकुले भ्राजमानम्",
            translation: "I bow down to the supreme controller, who is the embodiment of sat-chit-ananda.",
            hindiMeaning: "सच्चिदानंद स्वरूप गोकुल में विराजमान भगवान दामोदर को मैं प्रणाम करता हूँ।",
            commentary: "Sung during the sacred month of Kartik.",
            imageUrl: "https://images.unsplash.com/photo-1518241353330-0f7941c2d9b5?auto=format&fit=crop&w=500&q=80",
            audioUrl: "https://actions.google.com/sounds/v1/ambiences/morning_birds.ogg",
            author: "सत्यव्रत मुनि"
        )
    ]
    
    let categories = ["All", "Shloka", "Bhajan", "Mantra", "Satsang"]
    
    var filteredContent: [SacredContent] {
        contentList.filter { content in
            let matchesCategory = selectedCategory == "All" || content.category == selectedCategory
            let matchesSearch = searchQuery.isEmpty || content.title.contains(searchQuery) || (content.author?.contains(searchQuery) ?? false)
            return matchesCategory && matchesSearch
        }
    }
    
    public var body: some View {
        ZStack {
            PremiumUI.masterBackground()
            
            VStack(spacing: 0) {
                // MARK: - Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(ThemeManager.shared.textMuted)
                    
                    TextField("सर्च ज्ञान, भजन, मंत्र...", text: $searchQuery)
                        .foregroundColor(ThemeManager.shared.textPrimary)
                        .font(PremiumFonts.sans(size: 14))
                }
                .padding()
                .glassCard(borderRadius: 16)
                .padding()
                
                // MARK: - Categories Selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(categories, id: \.self) { cat in
                            Button(action: {
                                AppHapticFeedback.lightImpact()
                                withAnimation {
                                    selectedCategory = cat
                                }
                            }) {
                                Text(cat)
                                    .font(PremiumFonts.sans(size: 13, weight: .bold))
                                    .foregroundColor(selectedCategory == cat ? .white : ThemeManager.shared.textPrimary)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(selectedCategory == cat ? ThemeManager.shared.activeAccent : Color.clear)
                                    .cornerRadius(20)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(selectedCategory == cat ? Color.clear : ThemeManager.shared.borderColor, lineWidth: 1)
                                    )
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 12)
                
                // MARK: - Content List
                ScrollView {
                    LazyVStack(spacing: 16) {
                        Color.clear
                            .frame(height: 0)
                            .detectScroll()
                        
                        ForEach(filteredContent) { content in
                            Button(action: {
                                AppHapticFeedback.mediumImpact()
                                AudioService.shared.play(content)
                            }) {
                                HStack(spacing: 16) {
                                    let placeholderSymbol = content.category == "Bhajan" ? "music.note" : (content.category == "Mantra" ? "bell.fill" : "book.closed.fill")
                                    if ThemeManager.shared.uiLiteEnabled {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(ThemeManager.shared.borderColor)
                                                .frame(width: 60, height: 60)
                                            Image(systemName: placeholderSymbol)
                                                .foregroundColor(ThemeManager.shared.activeAccent)
                                        }
                                    } else {
                                        AsyncImage(url: URL(string: content.displayImageUrl)) { image in
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 60, height: 60)
                                                .cornerRadius(12)
                                                .clipped()
                                        } placeholder: {
                                            SacredImagePlaceholder(systemName: placeholderSymbol, width: 60, height: 60)
                                        }
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(content.displayTitle)
                                            .font(PremiumFonts.sans(size: 15, weight: .bold))
                                            .foregroundColor(ThemeManager.shared.textPrimary)
                                            .multilineTextAlignment(.leading)
                                        
                                        HStack(spacing: 8) {
                                            Text(content.author ?? "Unknown")
                                                .font(PremiumFonts.sans(size: 12))
                                                .foregroundColor(ThemeManager.shared.textMuted)
                                            
                                            Circle()
                                                .fill(ThemeManager.shared.textMuted)
                                                .frame(width: 4, height: 4)
                                            
                                            Text(content.category)
                                                .font(PremiumFonts.sans(size: 11, weight: .semibold))
                                                .foregroundColor(ThemeManager.shared.activeAccent)
                                        }
                                    }
                                    Spacer()
                                    
                                    Image(systemName: AudioService.shared.currentTrack?.id == content.id && AudioService.shared.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                        .font(.system(size: 28))
                                        .foregroundColor(ThemeManager.shared.activeAccent)
                                }
                                .padding()
                                .glassCard(borderRadius: 20)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                }
                .coordinateSpace(name: "scroll")
                
                Spacer()
                
                // Embedded Mini Audio Player (Lock screen/Background Audio controller)
                if let playingTrack = AudioService.shared.currentTrack {
                    VStack(spacing: 10) {
                        HStack(spacing: 14) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(playingTrack.displayTitle)
                                    .font(PremiumFonts.sans(size: 13, weight: .bold))
                                    .foregroundColor(ThemeManager.shared.textPrimary)
                                    .lineLimit(1)
                                
                                Text(playingTrack.author ?? "Sant-Vaani")
                                    .font(PremiumFonts.sans(size: 11))
                                    .foregroundColor(ThemeManager.shared.textMuted)
                                    .lineLimit(1)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                AppHapticFeedback.lightImpact()
                                if AudioService.shared.isPlaying {
                                    AudioService.shared.pause()
                                } else {
                                    AudioService.shared.resume()
                                }
                            }) {
                                Image(systemName: AudioService.shared.isPlaying ? "pause.fill" : "play.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(ThemeManager.shared.textPrimary)
                                    .padding(8)
                                    .glassCard(borderRadius: 10)
                            }
                        }
                        
                        let progress = AudioService.shared.duration > 0 ? (AudioService.shared.currentTime / AudioService.shared.duration) : 0.0
                        LiquidScrubberBar(value: progress) { targetPercent in
                            let targetTime = targetPercent * AudioService.shared.duration
                            AudioService.shared.seek(to: targetTime)
                        }
                        .frame(height: 6)
                        .padding(.top, 4)
                    }
                    .padding()
                    .glassCard(borderRadius: 16)
                    .padding(.horizontal)
                    .padding(.bottom, 90) // Pad above the navigation tabs
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
    }
}
