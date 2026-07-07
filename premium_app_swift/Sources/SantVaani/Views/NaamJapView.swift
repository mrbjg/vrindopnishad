import SwiftUI
import AVFoundation
import Combine

@Observable
public final class JapSessionViewModel {
    public var totalCount: Int {
        didSet {
            UserDefaults.standard.set(totalCount, forKey: "jap_total_count")
        }
    }
    public var todayCount: Int {
        didSet {
            UserDefaults.standard.set(todayCount, forKey: "jap_today_count")
            if todayCount > highestDailyJaps {
                highestDailyJaps = todayCount
            }
        }
    }
    public var highestDailyJaps: Int {
        didSet {
            UserDefaults.standard.set(highestDailyJaps, forKey: "jap_highest_daily")
        }
    }
    public var currentAmbiance: String = "None"
    public var isAudioPlaying: Bool = false
    public var isImmersive: Bool = false
    
    private var ambiancePlayer: AVPlayer?
    
    public init() {
        self.totalCount = UserDefaults.standard.integer(forKey: "jap_total_count")
        self.todayCount = UserDefaults.standard.integer(forKey: "jap_today_count")
        self.highestDailyJaps = UserDefaults.standard.integer(forKey: "jap_highest_daily")
    }
    
    public func incrementCount() {
        totalCount += 1
        todayCount += 1
        
        // Haptic feedback sequence: Light tap normally, triple heavy on Mala (108 chants) completion
        if todayCount > 0 && todayCount % 108 == 0 {
            AppHapticFeedback.heavyImpact()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                AppHapticFeedback.heavyImpact()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.24) {
                AppHapticFeedback.heavyImpact()
            }
        } else {
            AppHapticFeedback.lightImpact()
        }
    }
    
    public func resetSession() {
        totalCount -= todayCount
        todayCount = 0
        AppHapticFeedback.mediumImpact()
    }
    
    public func playAmbiance(_ track: String) {
        let ambianceTracks = [
            "None": "",
            "Sacred Drone": "https://actions.google.com/sounds/v1/ambiences/wind_constant.ogg",
            "Flowing Ganges": "https://actions.google.com/sounds/v1/ambiences/river_flowing.ogg",
            "Temple Chimes": "https://actions.google.com/sounds/v1/ambiences/morning_birds.ogg"
        ]
        
        guard let urlString = ambianceTracks[track] else { return }
        
        if urlString.isEmpty {
            ambiancePlayer?.pause()
            currentAmbiance = "None"
            isAudioPlaying = false
            return
        }
        
        guard let url = URL(string: urlString) else { return }
        
        let playerItem = AVPlayerItem(url: url)
        // Set audio loop
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: playerItem, queue: .main) { [weak self] _ in
            self?.ambiancePlayer?.seek(to: .zero)
            self?.ambiancePlayer?.play()
        }
        
        ambiancePlayer = AVPlayer(playerItem: playerItem)
        ambiancePlayer?.play()
        currentAmbiance = track
        isAudioPlaying = true
    }
}

public struct NaamJapView: View {
    @Binding public var isImmersiveParent: Bool
    
    @State private var viewModel = JapSessionViewModel()
    @State private var showAmbianceSheet = false
    @State private var breatheScale: CGFloat = 1.0
    @State private var dragOffset: CGSize = .zero
    @State private var isDraggingBead = false
    
    private var todayMalas: Double {
        Double(viewModel.todayCount) / 108.0
    }
    
    public var body: some View {
        let isDark = ThemeManager.shared.isDark
        ZStack {
            PremiumUI.masterBackground()
            
            // Rising Incense Sparks / Spiritual Particles
            if !ThemeManager.shared.uiLiteEnabled && !viewModel.isImmersive {
                SpiritualParticleEmitterView()
                    .ignoresSafeArea()
            } else if !ThemeManager.shared.uiLiteEnabled && viewModel.isImmersive {
                // More active particles during focus mode to enhance ambiance
                SpiritualParticleEmitterView(spawnInterval: 0.3)
                    .ignoresSafeArea()
            }
            
            VStack {
                if !viewModel.isImmersive {
                    // Header Bar
                    HStack {
                        Button(action: {
                            AppHapticFeedback.mediumImpact()
                            showAmbianceSheet = true
                        }) {
                            HStack {
                                Image(systemName: viewModel.isAudioPlaying ? "waveform.and.mic" : "music.note")
                                Text(viewModel.currentAmbiance)
                                    .font(PremiumFonts.sans(size: 13, weight: .semibold))
                            }
                            .foregroundColor(ThemeManager.shared.textPrimary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .glassCard(borderRadius: 16)
                        }
                        .interactiveLiquidGlass()
                        
                        Spacer()
                        
                        Button(action: {
                            AppHapticFeedback.mediumImpact()
                            withAnimation(.easeInOut) {
                                viewModel.isImmersive = true
                            }
                        }) {
                            Image(systemName: "eye.slash")
                                .foregroundColor(ThemeManager.shared.textPrimary)
                                .padding(10)
                                .glassCard(borderRadius: 12)
                        }
                        .interactiveLiquidGlass()
                    }
                    .padding(.horizontal)
                    .padding(.top)
                }
                
                Spacer()
                
                // Tap Interactive Counter Core
                VStack(spacing: 24) {
                    ZStack {
                        // Ambient Radial Glow
                        Circle()
                            .fill(ThemeManager.shared.activeAccent.opacity(viewModel.isImmersive ? 0.08 : 0.12))
                            .frame(width: 280, height: 280)
                            .evolvingAura(color: ThemeManager.shared.activeAccent, intensity: 1.5)
                            .scaleEffect(breatheScale)
                        
                        // Inner glow backdrop
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        ThemeManager.shared.activeAccent.opacity(isDark ? 0.08 : 0.12),
                                        Color.clear
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 210, height: 210)
                            .scaleEffect(breatheScale)
                        
                        // Circular Progress Tracker
                        Circle()
                            .stroke(ThemeManager.shared.borderColor, lineWidth: 8)
                            .frame(width: 220, height: 220)
                            .scaleEffect(breatheScale)
                        
                        Circle()
                            .trim(from: 0.0, to: CGFloat(min(todayMalas - floor(todayMalas), 0.999)))
                            .stroke(
                                LinearGradient(colors: ThemeManager.shared.activeGradient, startPoint: .top, endPoint: .bottom),
                                style: StrokeStyle(lineWidth: 12, lineCap: .round)
                            )
                            .frame(width: 220, height: 220)
                            .rotationEffect(Angle(degrees: -90))
                            .scaleEffect(breatheScale)
                        
                        // Numeric Display
                        VStack(spacing: 4) {
                            Text("\(viewModel.todayCount % 108)")
                                .font(PremiumFonts.display(size: 54, weight: .bold))
                                .foregroundColor(ThemeManager.shared.textPrimary)
                            
                            Text("Beads")
                                .font(PremiumFonts.sans(size: 14, weight: .medium))
                                .foregroundColor(ThemeManager.shared.textMuted)
                            
                            Text("Mala \(Int(todayMalas) + 1)")
                                .font(PremiumFonts.sans(size: 12, weight: .semibold))
                                .foregroundColor(ThemeManager.shared.activeAccent)
                                .padding(.top, 4)
                        }
                    }
                    .contentShape(Circle())
                    .offset(dragOffset)
                    // Liquid droplet vertical stretch effect
                    .scaleEffect(
                        x: isDraggingBead ? 1.0 - (min(max(dragOffset.height, 0), 120.0) / 700.0) : 1.0,
                        y: isDraggingBead ? 1.0 + (min(max(dragOffset.height, 0), 120.0) / 320.0) : 1.0,
                        anchor: .top
                    )
                    .gesture(
                        DragGesture()
                            .onChanged { val in
                                isDraggingBead = true
                                let pull = val.translation.height
                                if pull > 0 {
                                    // Dragging down: move bead down with slight friction
                                    dragOffset = CGSize(width: val.translation.width * 0.12, height: pull * 0.82)
                                } else {
                                    // Resisting upward drag
                                    dragOffset = CGSize(width: val.translation.width * 0.08, height: pull * 0.20)
                                }
                                
                                // Tick haptics on pull milestones
                                if Int(pull) % 20 == 0 {
                                    AppHapticFeedback.lightImpact()
                                }
                            }
                            .onEnded { val in
                                isDraggingBead = false
                                let pull = val.translation.height
                                if pull > 65 {
                                    // Bead pulled successfully past thread -> Chant registered!
                                    viewModel.incrementCount()
                                    AppHapticFeedback.heavyImpact()
                                } else {
                                    AppHapticFeedback.mediumImpact()
                                }
                                withAnimation(.spring(response: 0.36, dampingFraction: 0.54)) {
                                    dragOffset = .zero
                                }
                            }
                    )
                    .onTapGesture {
                        viewModel.incrementCount()
                    }
                    
                    if viewModel.isImmersive {
                        Text("TAP ANYWHERE TO JAP")
                            .font(PremiumFonts.sans(size: 11, weight: .bold))
                            .tracking(3)
                            .foregroundColor(ThemeManager.shared.textMuted)
                            .padding(.top, 20)
                            .transition(.opacity)
                            .onTapGesture {
                                viewModel.incrementCount()
                            }
                    } else {
                        VStack(spacing: 8) {
                            Text("\(viewModel.totalCount)")
                                .font(PremiumFonts.display(size: 32, weight: .bold))
                                .foregroundColor(ThemeManager.shared.textPrimary)
                            Text("TOTAL CHANTS")
                                .font(PremiumFonts.sans(size: 10, weight: .black))
                                .tracking(2)
                                .foregroundColor(ThemeManager.shared.textMuted)
                        }
                    }
                }
                
                Spacer()
                
                if viewModel.isImmersive {
                    // Back button for Immersive mode
                    Button(action: {
                        AppHapticFeedback.mediumImpact()
                        withAnimation(.easeInOut) {
                            viewModel.isImmersive = false
                        }
                    }) {
                        Text("Exit Focus")
                            .font(PremiumFonts.sans(size: 13, weight: .bold))
                            .foregroundColor(ThemeManager.shared.activeAccent)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 10)
                            .glassCard(borderRadius: 20)
                    }
                    .interactiveLiquidGlass()
                    .padding(.bottom, 40)
                } else {
                    // Session statistics and resets
                    HStack(spacing: 40) {
                        VStack(alignment: .center, spacing: 4) {
                            Text(String(format: "%.1f", todayMalas))
                                .font(PremiumFonts.sans(size: 20, weight: .bold))
                                .foregroundColor(ThemeManager.shared.textPrimary)
                            Text("TODAY MALAS")
                                .font(PremiumFonts.sans(size: 9, weight: .semibold))
                                .foregroundColor(ThemeManager.shared.textMuted)
                        }
                        
                        VStack(alignment: .center, spacing: 4) {
                            Text(String(format: "%.1f", Double(viewModel.highestDailyJaps) / 108.0))
                                .font(PremiumFonts.sans(size: 20, weight: .bold))
                                .foregroundColor(ThemeManager.shared.textPrimary)
                            Text("HIGHEST DAILY")
                                .font(PremiumFonts.sans(size: 9, weight: .semibold))
                                .foregroundColor(ThemeManager.shared.textMuted)
                        }
                        
                        Button(action: {
                            viewModel.resetSession()
                        }) {
                            VStack(alignment: .center, spacing: 4) {
                                Image(systemName: "arrow.counterclockwise")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.red)
                                Text("RESET")
                                    .font(PremiumFonts.sans(size: 8, weight: .bold))
                                    .foregroundColor(ThemeManager.shared.textSecondary)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .glassCard(borderRadius: 10)
                            .glassTint(.red, intensity: 0.12, borderRadius: 10)
                        }
                        .interactiveLiquidGlass()
                    }
                    .padding(.bottom, 60)
                }
            }
            .allowsHitTesting(true)
            .background(
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        // Allow tapping anywhere on the screen in immersive mode to count
                        if viewModel.isImmersive {
                            viewModel.incrementCount()
                        }
                    }
            )
        }
        .onAppear {
            isImmersiveParent = viewModel.isImmersive
            if !ThemeManager.shared.uiLiteEnabled {
                withAnimation(
                    .easeInOut(duration: 4.5)
                    .repeatForever(autoreverses: true)
                ) {
                    breatheScale = 1.05
                }
            }
        }
        .onChange(of: viewModel.isImmersive) { oldValue, newValue in
            withAnimation(.easeInOut) {
                isImmersiveParent = newValue
            }
        }
        .sheet(isPresented: $showAmbianceSheet) {
            AmbianceSelectionView(selected: viewModel.currentAmbiance) { selectedTrack in
                viewModel.playAmbiance(selectedTrack)
            }
            .presentationDetents([.fraction(0.4)])
            .presentationBackground(.ultraThinMaterial)
        }
    }
}

// MARK: - Ambiance Sheet Selection View
struct AmbianceSelectionView: View {
    let selected: String
    let onSelect: (String) -> Void
    
    let tracks = ["None", "Sacred Drone", "Flowing Ganges", "Temple Chimes"]
    
    var body: some View {
        VStack(spacing: 20) {
            Capsule()
                .fill(ThemeManager.shared.textMuted.opacity(0.3))
                .frame(width: 40, height: 4)
                .padding(.top, 12)
            
            Text("SELECT AMBIANCE")
                .font(PremiumFonts.sans(size: 14, weight: .black))
                .tracking(4)
                .foregroundColor(ThemeManager.shared.textPrimary)
            
            ScrollView {
                VStack(spacing: 4) {
                    ForEach(tracks, id: \.self) { track in
                        Button(action: {
                            AppHapticFeedback.lightImpact()
                            onSelect(track)
                        }) {
                            HStack {
                                Text(track)
                                    .font(PremiumFonts.sans(size: 15, weight: selected == track ? .bold : .regular))
                                    .foregroundColor(selected == track ? ThemeManager.shared.activeAccent : ThemeManager.shared.textPrimary)
                                
                                Spacer()
                                
                                if selected == track {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(ThemeManager.shared.activeAccent)
                                }
                            }
                            .padding(.vertical, 14)
                            .padding(.horizontal)
                        }
                        Divider()
                            .padding(.horizontal)
                    }
                }
            }
            Spacer()
        }
    }
}

// MARK: - Spiritual Particle Emitter View
struct SpiritualParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var scale: CGFloat
    var opacity: Double
    var speed: CGFloat
}

struct SpiritualParticleEmitterView: View {
    public var spawnInterval: Double = 0.6
    @State private var particles: [SpiritualParticle] = []
    
    // Timer to spawn particles
    private let spawnTimer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    // Timer to update particle coordinates
    private let updateTimer = Timer.publish(every: 0.04, on: .main, in: .common).autoconnect()
    
    var body: some View {
        let accent = ThemeManager.shared.activeAccent
        
        ZStack {
            ForEach(particles) { particle in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [accent.opacity(particle.opacity), Color.clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 4 * particle.scale
                        )
                    )
                    .frame(width: 8 * particle.scale, height: 8 * particle.scale)
                    .position(x: particle.x, y: particle.y)
            }
        }
        .onReceive(spawnTimer) { _ in
            let screenWidth = UIScreen.main.bounds.width
            let screenHeight = UIScreen.main.bounds.height
            
            let newParticle = SpiritualParticle(
                x: CGFloat.random(in: 40...(screenWidth - 40)),
                y: screenHeight - 80,
                scale: CGFloat.random(in: 0.6...2.0),
                opacity: Double.random(in: 0.4...0.9),
                speed: CGFloat.random(in: 1.5...3.5)
            )
            particles.append(newParticle)
        }
        .onReceive(updateTimer) { _ in
            particles = particles.map { p in
                var updated = p
                updated.y -= p.speed
                updated.opacity -= 0.008
                return updated
            }.filter { $0.y > 0 && $0.opacity > 0 }
        }
    }
}
