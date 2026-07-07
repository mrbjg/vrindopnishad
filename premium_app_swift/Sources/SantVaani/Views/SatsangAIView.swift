import SwiftUI

public struct SatsangResponse: Identifiable, Equatable {
    public let id = UUID()
    public let query: String
    public let verse: String?
    public let translation: String?
    public let answer: String
}

public struct SatsangAIView: View {
    @Binding var isExpanded: Bool
    
    @State private var queryText = ""
    @State private var isThinking = false
    @State private var response: SatsangResponse? = nil
    @State private var thinkingProgress: CGFloat = 0.0
    @State private var suggestions = [
        "मन शांत कैसे करें?",
        "कर्म का सिद्धांत क्या है?",
        "साधना में मन कैसे लगाएं?",
        "सच्चा सुख कहाँ है?"
    ]
    
    @Namespace private var barNamespace
    @FocusState private var isInputFocused: Bool
    
    public init(isExpanded: Binding<Bool>) {
        self._isExpanded = isExpanded
    }
    
    public var body: some View {
        ZStack {
            if isExpanded {
                // Dimmed background backdrop to focus on chat drawer
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.38, dampingFraction: 0.78)) {
                            isInputFocused = false
                            isExpanded = false
                        }
                    }
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    // Expanded Chat Drawer Panel
                    VStack(spacing: 16) {
                        // Drag Indicator & Close handle
                        HStack {
                            Capsule()
                                .fill(ThemeManager.shared.textMuted.opacity(0.3))
                                .frame(width: 40, height: 4)
                        }
                        .padding(.top, 8)
                        
                        // Header Title
                        HStack {
                            Text("ॐ सत्संग AI (Spiritual Guide)")
                                .font(PremiumFonts.sans(size: 14, weight: .black))
                                .tracking(1)
                                .foregroundColor(ThemeManager.shared.textPrimary)
                            
                            Spacer()
                            
                            Button(action: {
                                AppHapticFeedback.lightImpact()
                                withAnimation(.spring(response: 0.38, dampingFraction: 0.78)) {
                                    isInputFocused = false
                                    isExpanded = false
                                }
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(ThemeManager.shared.textMuted)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Response Area
                        ScrollView {
                            VStack(spacing: 16) {
                                if let resp = response {
                                    // User prompt echo card
                                    HStack {
                                        Spacer()
                                        Text(resp.query)
                                            .font(PremiumFonts.sans(size: 14, weight: .medium))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 10)
                                            .background(ThemeManager.shared.activeAccent.opacity(0.85))
                                            .cornerRadius(18)
                                    }
                                    .padding(.horizontal)
                                    
                                    // AI Translucent Response Card
                                    VStack(alignment: .leading, spacing: 14) {
                                        HStack {
                                            Image(systemName: "sparkles")
                                                .foregroundColor(ThemeManager.shared.activeAccent)
                                            Text("गुरु वाणी (Guru AI Guidance)")
                                                .font(PremiumFonts.sans(size: 12, weight: .bold))
                                                .foregroundColor(ThemeManager.shared.activeAccent)
                                        }
                                        
                                        if let verse = resp.verse {
                                            // Sacred Shloka block
                                            Text(verse)
                                                .font(PremiumFonts.hindiAware(size: 14, text: verse, weight: .semibold, isSacred: true))
                                                .multilineTextAlignment(.leading)
                                                .foregroundColor(ThemeManager.shared.textPrimary)
                                                .lineSpacing(6)
                                                .padding()
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .background(Color.white.opacity(ThemeManager.shared.isDark ? 0.05 : 0.15))
                                                .cornerRadius(12)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(ThemeManager.shared.activeAccent.opacity(0.2), lineWidth: 0.8)
                                                )
                                        }
                                        
                                        if let trans = resp.translation {
                                            Text("अनुवाद:")
                                                .font(PremiumFonts.sans(size: 11, weight: .bold))
                                                .foregroundColor(ThemeManager.shared.textMuted)
                                            Text(trans)
                                                .font(PremiumFonts.sans(size: 13, weight: .medium))
                                                .foregroundColor(ThemeManager.shared.textSecondary)
                                                .lineSpacing(4)
                                        }
                                        
                                        Divider()
                                            .background(ThemeManager.shared.borderColor.opacity(0.3))
                                        
                                        Text(resp.answer)
                                            .font(PremiumFonts.sans(size: 14))
                                            .foregroundColor(ThemeManager.shared.textPrimary)
                                            .lineSpacing(5)
                                    }
                                    .padding()
                                    .glassCard(borderRadius: 20)
                                    .padding(.horizontal)
                                    .transition(.asymmetric(insertion: .move(edge: .bottom).combined(with: .opacity), removal: .opacity))
                                } else if isThinking {
                                    // Illuminated "Thinking" Shimmering Glass Card
                                    VStack(alignment: .leading, spacing: 12) {
                                        HStack(spacing: 8) {
                                            Circle()
                                                .fill(ThemeManager.shared.activeAccent)
                                                .frame(width: 6, height: 6)
                                            Circle()
                                                .fill(ThemeManager.shared.activeAccent)
                                                .frame(width: 6, height: 6)
                                            Circle()
                                                .fill(ThemeManager.shared.activeAccent)
                                                .frame(width: 6, height: 6)
                                        }
                                        .opacity(0.8)
                                        
                                        Text("शास्त्रों से उत्तर खोजा जा रहा है...")
                                            .font(PremiumFonts.sans(size: 13, weight: .medium))
                                            .foregroundColor(ThemeManager.shared.textSecondary)
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .glassCard(borderRadius: 16)
                                    .overlay(
                                        // Specular light thinking sweep
                                        GeometryReader { geo in
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(
                                                    LinearGradient(
                                                        colors: [
                                                            Color.clear,
                                                            ThemeManager.shared.activeAccent.opacity(0.8),
                                                            Color.cyan.opacity(0.8),
                                                            Color.clear
                                                        ],
                                                        startPoint: .leading,
                                                        endPoint: .trailing
                                                    ),
                                                    lineWidth: 2.0
                                                )
                                                .offset(x: thinkingProgress * geo.size.width * 2 - geo.size.width)
                                        }
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                    )
                                    .padding(.horizontal)
                                    .onAppear {
                                        withAnimation(.linear(duration: 1.8).repeatForever(autoreverses: false)) {
                                            thinkingProgress = 1.0
                                        }
                                    }
                                } else {
                                    // Welcome prompt instructions
                                    VStack(spacing: 8) {
                                        Text("🪷")
                                            .font(.system(size: 32))
                                        Text("सत्संग AI आपका स्वागत करता है।")
                                            .font(PremiumFonts.sans(size: 15, weight: .bold))
                                            .foregroundColor(ThemeManager.shared.textPrimary)
                                        Text("अपने आध्यात्मिक प्रश्नों को पूछें या नीचे दी गई किसी प्रेरणादायक सुझाव पर टैप करें।")
                                            .font(PremiumFonts.sans(size: 12))
                                            .foregroundColor(ThemeManager.shared.textMuted)
                                            .multilineTextAlignment(.center)
                                            .padding(.horizontal, 30)
                                    }
                                    .padding(.vertical, 40)
                                }
                            }
                            .padding(.vertical)
                        }
                        
                        // Contextual Glass Overlays: Suggestions Row
                        if !isThinking && response == nil {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(suggestions, id: \.self) { sug in
                                        Button(action: {
                                            AppHapticFeedback.lightImpact()
                                            queryText = sug
                                            askAIEngine()
                                        }) {
                                            Text(sug)
                                                .font(PremiumFonts.sans(size: 12, weight: .semibold))
                                                .foregroundColor(ThemeManager.shared.textPrimary)
                                                .padding(.horizontal, 14)
                                                .padding(.vertical, 8)
                                                .glassCard(borderRadius: 16)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .padding(.bottom, 4)
                        }
                        
                        // Text input capsule area
                        HStack(spacing: 12) {
                            TextField("शास्त्रों से प्रश्न पूछें...", text: $queryText)
                                .font(PremiumFonts.sans(size: 14))
                                .foregroundColor(ThemeManager.shared.textPrimary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color.white.opacity(ThemeManager.shared.isDark ? 0.05 : 0.10))
                                .cornerRadius(24)
                                .focused($isInputFocused)
                            
                            Button(action: {
                                askAIEngine()
                            }) {
                                Image(systemName: "paperplane.fill")
                                    .font(.system(size: 15))
                                    .foregroundColor(.white)
                                    .padding(12)
                                    .background(Circle().fill(queryText.isEmpty ? ThemeManager.shared.activeAccent.opacity(0.4) : ThemeManager.shared.activeAccent))
                            }
                            .disabled(queryText.isEmpty)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 24)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .fill(.ultraThinMaterial.opacity(0.95))
                            .shadow(color: Color.black.opacity(0.3), radius: 24, x: 0, y: -10)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(Color.white.opacity(0.18), lineWidth: 1.0)
                    )
                    .matchedGeometryEffect(id: "commandBar", in: barNamespace)
                }
                .ignoresSafeArea(.keyboard)
                .transition(.move(edge: .bottom))
                .onAppear {
                    isInputFocused = true
                }
            } else {
                // Collapsed State: Sleek Capsule Command Bar Floating Button
                VStack {
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            AppHapticFeedback.mediumImpact()
                            withAnimation(.spring(response: 0.38, dampingFraction: 0.74)) {
                                isExpanded = true
                            }
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(ThemeManager.shared.activeAccent)
                                
                                Text("पूछें गुरु AI से...")
                                    .font(PremiumFonts.sans(size: 12, weight: .bold))
                                    .foregroundColor(ThemeManager.shared.textPrimary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                ZStack {
                                    // Liquid glass background
                                    Capsule()
                                        .fill(.ultraThinMaterial.opacity(0.85))
                                    Capsule()
                                        .stroke(ThemeManager.shared.activeAccent.opacity(0.35), lineWidth: 1.2)
                                }
                            )
                            .shadow(color: ThemeManager.shared.activeAccent.opacity(0.12), radius: 8, x: 0, y: 4)
                        }
                        .buttonStyle(InteractiveLiquidGlassButtonStyle())
                        .matchedGeometryEffect(id: "commandBar", in: barNamespace)
                        
                        Spacer()
                    }
                    .padding(.bottom, 104) // Floating just above bottom tabs / player
                }
                .ignoresSafeArea(.keyboard)
            }
        }
    }
    
    private func askAIEngine() {
        guard !queryText.isEmpty else { return }
        AppHapticFeedback.mediumImpact()
        isInputFocused = false
        
        withAnimation {
            isThinking = true
            response = nil
        }
        
        let query = queryText
        queryText = ""
        
        // Simulating the AI generator response matching topics (Man, Karma, Sadhana)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            let lower = query.lowercased()
            let resp: SatsangResponse
            
            if lower.contains("मन") || lower.contains("शांत") || lower.contains("mind") || lower.contains("peace") {
                resp = SatsangResponse(
                    query: query,
                    verse: "चंचलं हि मनः कृष्ण प्रमाथि बलवद्द्ढम्।\nतस्याहं निग्रहं मन्ये वायोरिव सुदुष्करम्॥",
                    translation: "हे कृष्ण! मन बड़ा ही चंचल, प्रमथनशील, अत्यंत दृढ़ और बलवान् है। उसको वश में करना मैं वायु को रोकने की भाँति अत्यंत दुष्कर मानता हूँ।",
                    answer: "शास्त्रों के अनुसार मन को नियंत्रित करने के दो ही मुख्य साधन हैं: 'अभ्यास' और 'वैराग्य'। जब भी ध्यान भटके, प्रेमपूर्वक मन को भगवान के पवित्र नाम जप की ओर वापस लाएं। नियमित प्राणायाम और श्वास प्रेक्षण साधना से भी मन शांत होता है।"
                )
            } else if lower.contains("कर्म") || lower.contains("karma") || lower.contains("duty") {
                resp = SatsangResponse(
                    query: query,
                    verse: "कर्मण्येवाधिकारस्ते मा फलेषु कदाचन।\nमा कर्मफलहेतुर्भूर्मा ते सङ्गोऽस्त्वकर्मणि॥",
                    translation: "कर्म करने में ही तुम्हारा अधिकार है, उसके फलों में कभी नहीं। तुम कर्मों के फल की वासना वाले मत होओ और तुम्हारी कर्म न करने में भी प्रीति न हो।",
                    answer: "गीता का कर्मयोग सिखाता है कि कर्तव्य समझकर किया गया निष्काम कर्म ही मनुष्य को आनंद और मुक्ति प्रदान करता है। अपनी आकांक्षाओं को ईश्वर में समर्पित करें और प्रत्येक कार्य को 'ईश्वर सेवा' के भाव से करें।"
                )
            } else if lower.contains("साधना") || lower.contains("ध्यान") || lower.contains("meditation") || lower.contains("focus") {
                resp = SatsangResponse(
                    query: query,
                    verse: "अभ्यासेन तु कौन्तेय वैराग्येण च गृह्यते।",
                    translation: "हे कुन्तीपुत्र! निःसंदेह चंचल मन को वश में करना कठिन है, परन्तु इसे अभ्यास और अनासक्ति (वैराग्य) द्वारा जीता जा सकता है।",
                    answer: "साधना की सफलता निरंतरता में है। ब्रह्ममुहूर्त (सुबह ४ से ६ बजे) में साधना करने से वातावरण का आध्यात्मिक स्पंदन मन को शांत करने में सहायक होता है। मंत्र जप करते समय शब्दों की ध्वनि को ध्यान से सुनने का प्रयास करें।"
                )
            } else {
                resp = SatsangResponse(
                    query: query,
                    verse: "यदा यदा हि धर्मस्य ग्लानिर्भवति भारत।\nअभ्युत्थानमधर्मस्य तदात्मानं सृजाम्यहम्॥",
                    translation: "हे भारत! जब-जब धर्म की हानि और अधर्म की वृद्धि होती है, तब-तब ही मैं अपने रूप को साकार रचता हूँ अर्थात् प्रकट होता हूँ।",
                    answer: "आध्यात्मिक मार्ग पर प्रगति के लिए नित्य नाम जप, सत्संग (अच्छे विचारों का संग) और स्वाध्याय (धार्मिक ग्रंथों का अध्ययन) करें। अपने जीवन में दया, सरलता और संतोष के भाव का अभ्यास करें। ईश्वर आपके अंतःकरण में सदैव उपस्थित हैं।"
                )
            }
            
            withAnimation(.spring(response: 0.42, dampingFraction: 0.76)) {
                isThinking = false
                response = resp
            }
            AppHapticFeedback.heavyImpact()
        }
    }
}
