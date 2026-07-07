import SwiftUI

#if canImport(UIKit)
import UIKit

// MARK: - Safe Haptic Feedback Helper
public struct AppHapticFeedback {
    public static func trigger(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        guard ThemeManager.shared.hapticEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
    
    public static func lightImpact() {
        trigger(.light)
    }
    
    public static func mediumImpact() {
        trigger(.medium)
    }
    
    public static func heavyImpact() {
        trigger(.heavy)
    }
    
    public static func selectionChanged() {
        guard ThemeManager.shared.hapticEnabled else { return }
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
}
#else
// Fallback for non-UIKit platforms (like macOS CLI build checks)
public struct AppHapticFeedback {
    public static func lightImpact() {}
    public static func mediumImpact() {}
    public static func heavyImpact() {}
    public static func selectionChanged() {}
}
#endif

// MARK: - Glassmorphic Card ViewModifier
public struct GlassCardModifier: ViewModifier {
    public var blurRadius: CGFloat
    public var opacity: Double
    public var borderRadius: CGFloat
    public var borderOpacity: Double

    public func body(content: Content) -> some View {
        let isDark = ThemeManager.shared.isDark
        if ThemeManager.shared.uiLiteEnabled {
            // Low-performance mode fallback: bypass GPU-heavy blurs
            content
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: borderRadius)
                        .fill(isDark ? Color(hex: 0xFF0A0A15) : Color.white)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: borderRadius)
                        .stroke(ThemeManager.shared.borderColor.opacity(borderOpacity * 2), lineWidth: 1.0)
                )
        } else {
            // Premium high-performance mode: real liquid glass material
            content
                .padding()
                .background(
                    ZStack {
                        // 1. Frosty glass base
                        RoundedRectangle(cornerRadius: borderRadius)
                            .fill(.ultraThinMaterial.opacity(opacity))
                        
                        // 2. Liquid depth reflection
                        RoundedRectangle(cornerRadius: borderRadius)
                            .fill(LinearGradient(
                                colors: [
                                    Color.white.opacity(isDark ? 0.08 : 0.20),
                                    Color.clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                        
                        // 3. Specular Liquid Sheen
                        GeometryReader { geo in
                            let gradient = LinearGradient(
                                colors: [
                                    Color.white.opacity(isDark ? 0.12 : 0.28),
                                    Color.clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            
                            Path { path in
                                path.move(to: CGPoint(x: 0, y: 0))
                                path.addLine(to: CGPoint(x: geo.size.width, y: 0))
                                path.addQuadCurve(
                                    to: CGPoint(x: 0, y: geo.size.height * 0.35),
                                    control: CGPoint(x: geo.size.width * 0.25, y: geo.size.height * 0.08)
                                )
                                path.closeSubpath()
                            }
                            .fill(gradient)
                        }
                    }
                )
                .overlay(
                    // 4. Glossy Outer Border Highlight (Simulating 3D refraction)
                    RoundedRectangle(cornerRadius: borderRadius)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(borderOpacity * 3.8),
                                    Color.white.opacity(borderOpacity * 0.1),
                                    ThemeManager.shared.activeAccent.opacity(borderOpacity * 0.9),
                                    Color.white.opacity(borderOpacity * 1.5)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
                .shadow(color: Color.black.opacity(isDark ? 0.30 : 0.08), radius: 12, x: 0, y: 6)
                .shadow(color: ThemeManager.shared.activeAccent.opacity(isDark ? 0.08 : 0.04), radius: 16, x: 0, y: 0)
        }
    }
}

extension View {
    public func glassCard(
        blurRadius: CGFloat = 15.0,
        opacity: Double = 0.5,
        borderRadius: CGFloat = 24.0,
        borderOpacity: Double = 0.12
    ) -> some View {
        self.modifier(GlassCardModifier(
            blurRadius: blurRadius,
            opacity: opacity,
            borderRadius: borderRadius,
            borderOpacity: borderOpacity
        ))
    }
    
    public func glassTint(_ color: Color, intensity: Double = 0.15, borderRadius: CGFloat = 16) -> some View {
        self.modifier(GlassTintModifier(color: color, intensity: intensity, borderRadius: borderRadius))
    }
}

// MARK: - Interactive Liquid Glass Button Style
public struct InteractiveLiquidGlassButtonStyle: ButtonStyle {
    public init() {}
    
    public func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed
        
        configuration.label
            .scaleEffect(isPressed ? 0.94 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.60), value: isPressed)
            .background(
                ZStack {
                    // Under-glass tap glow
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            RadialGradient(
                                colors: [
                                    ThemeManager.shared.activeAccent.opacity(0.35),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 100
                            )
                        )
                        .opacity(isPressed ? 1.0 : 0.0)
                        .animation(.easeOut(duration: 0.15), value: isPressed)
                }
            )
    }
}

extension View {
    public func interactiveLiquidGlass() -> some View {
        self.buttonStyle(InteractiveLiquidGlassButtonStyle())
    }
}

// MARK: - Glass Tint ViewModifier
public struct GlassTintModifier: ViewModifier {
    public var color: Color
    public var intensity: Double
    public var borderRadius: CGFloat
    
    public func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: borderRadius)
                    .fill(color.opacity(intensity))
                    .allowsHitTesting(false)
            )
    }
}


// MARK: - Evolving Background Orbs
public struct MovingBackgroundOrbs: View {
    @State private var orb1Offset = CGSize(width: -80, height: -120)
    @State private var orb2Offset = CGSize(width: 80, height: 120)
    @State private var orb3Offset = CGSize(width: -120, height: 180)
    
    public var body: some View {
        let accent = ThemeManager.shared.activeAccent
        let isDark = ThemeManager.shared.isDark
        
        GeometryReader { geo in
            ZStack {
                // Orb 1: Accent glow
                Circle()
                    .fill(accent.opacity(isDark ? 0.14 : 0.22))
                    .frame(width: 260, height: 260)
                    .offset(orb1Offset)
                    .blur(radius: 65)
                
                // Orb 2: Light accent secondary glow
                Circle()
                    .fill(ThemeManager.shared.activeAccentLight.opacity(isDark ? 0.10 : 0.18))
                    .frame(width: 320, height: 320)
                    .offset(orb2Offset)
                    .blur(radius: 75)
                    
                // Orb 3: Soft ambient glow
                Circle()
                    .fill((isDark ? Color.purple : Color.orange).opacity(isDark ? 0.08 : 0.14))
                    .frame(width: 220, height: 220)
                    .offset(orb3Offset)
                    .blur(radius: 55)
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 8.0)
                    .repeatForever(autoreverses: true)
                ) {
                    orb1Offset = CGSize(width: 90, height: -60)
                }
                withAnimation(
                    .easeInOut(duration: 10.0)
                    .repeatForever(autoreverses: true)
                ) {
                    orb2Offset = CGSize(width: -90, height: 40)
                }
                withAnimation(
                    .easeInOut(duration: 12.0)
                    .repeatForever(autoreverses: true)
                ) {
                    orb3Offset = CGSize(width: 60, height: -140)
                }
            }
        }
    }
}

// MARK: - Sacred Image Placeholder
public struct SacredImagePlaceholder: View {
    public var systemName: String
    public var width: CGFloat
    public var height: CGFloat
    
    @State private var rotateDegrees = 0.0
    
    public init(systemName: String = "wand.and.stars", width: CGFloat = 60, height: CGFloat = 60) {
        self.systemName = systemName
        self.width = width
        self.height = height
    }
    
    public var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [
                            ThemeManager.shared.activeAccent.opacity(0.18),
                            ThemeManager.shared.activeAccentLight.opacity(0.04),
                            ThemeManager.shared.activeAccentDark.opacity(0.12)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            // Soft glowing background circle
            Circle()
                .fill(ThemeManager.shared.activeAccent.opacity(0.15))
                .frame(width: width * 0.7, height: height * 0.7)
                .blur(radius: 6)
            
            Image(systemName: systemName)
                .font(.system(size: width * 0.38, weight: .semibold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            ThemeManager.shared.activeAccentLight,
                            ThemeManager.shared.activeAccent
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .rotationEffect(Angle(degrees: rotateDegrees))
                .onAppear {
                    if !ThemeManager.shared.uiLiteEnabled {
                        withAnimation(
                            .linear(duration: 12.0)
                            .repeatForever(autoreverses: false)
                        ) {
                            rotateDegrees = 360.0
                        }
                    }
                }
        }
        .frame(width: width, height: height)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(ThemeManager.shared.activeAccent.opacity(0.15), lineWidth: 0.8)
        )
    }
}


// MARK: - Evolving Aura Glowing Modifier
public struct EvolvingAuraModifier: ViewModifier {
    public var color: Color
    public var intensity: Double
    @State private var pulse: CGFloat = 1.0

    public func body(content: Content) -> some View {
        if ThemeManager.shared.uiLiteEnabled {
            // Low performance mode: flat shadow representation
            content
                .shadow(color: color.opacity(0.3 * intensity), radius: 10, x: 0, y: 0)
        } else {
            // Premium mode: pulsing ambient glow
            content
                .background(
                    Circle()
                        .fill(color.opacity(0.15 * intensity))
                        .scaleEffect(pulse)
                        .blur(radius: 20)
                        .onAppear {
                            withAnimation(
                                .easeInOut(duration: 2.5)
                                .repeatForever(autoreverses: true)
                            ) {
                                pulse = 1.3
                            }
                        }
                )
        }
    }
}

extension View {
    public func evolvingAura(color: Color, intensity: Double = 1.0) -> some View {
        self.modifier(EvolvingAuraModifier(color: color, intensity: intensity))
    }
}

// MARK: - Global Helper Components
public struct PremiumUI {
    
    // Category badge with contrast safety
    @ViewBuilder
    public static func categoryBadge(_ label: String) -> some View {
        let isDark = ThemeManager.shared.isDark
        let accent = ThemeManager.shared.activeAccent
        let accentLight = ThemeManager.shared.activeAccentLight
        let textColor = isDark ? accentLight : accent
        let bgColor = isDark ? accent.opacity(0.20) : accent.opacity(0.12)
        let borderColor = isDark ? accentLight.opacity(0.30) : accent.opacity(0.25)

        Text(label.uppercased())
            .font(PremiumFonts.sans(size: 11, weight: .black))
            .tracking(1)
            .foregroundColor(textColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(bgColor)
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(borderColor, lineWidth: 0.8)
            )
    }

    // Resonance percentage badge
    @ViewBuilder
    public static func resonanceBadge(_ label: String) -> some View {
        let isDark = ThemeManager.shared.isDark
        let accent = ThemeManager.shared.activeAccent
        let accentLight = ThemeManager.shared.activeAccentLight
        let textColor = isDark ? accentLight : accent
        let bgColor = isDark ? Color.black.opacity(0.5) : accent.opacity(0.12)
        let borderColor = isDark ? accentLight.opacity(0.30) : accent.opacity(0.25)

        Text(label)
            .font(PremiumFonts.sans(size: 10, weight: .bold))
            .foregroundColor(textColor)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(bgColor)
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(borderColor, lineWidth: 0.8)
            )
    }

    // Dynamic Master Background view
    @ViewBuilder
    public static func masterBackground() -> some View {
        let moodColors = ThemeManager.shared.backgroundGradient
        
        ZStack {
            ThemeManager.shared.scaffoldBg
                .ignoresSafeArea()
            
            LinearGradient(
                gradient: Gradient(colors: moodColors),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            if !ThemeManager.shared.uiLiteEnabled {
                // Slowly moving colored orbs in the background
                MovingBackgroundOrbs()
                    .ignoresSafeArea()
            }
            
            // Add subtle radial light blur at the top center for atmospheric ambiance
            if !ThemeManager.shared.uiLiteEnabled {
                RadialGradient(
                    gradient: Gradient(colors: [ThemeManager.shared.activeAccent.opacity(0.10), .clear]),
                    center: .top,
                    startRadius: 0,
                    endRadius: 500
                )
                .ignoresSafeArea()
            }
        }
    }
}

// MARK: - Extension to check dark mode of ThemeManager easily
extension ThemeManager {
    public var isDark: Bool {
        activeMoodPalette.isDark
    }
}

// MARK: - Scroll Tracking Preference Key
public struct ScrollOffsetPreferenceKey: PreferenceKey {
    public static var defaultValue: CGFloat = 0
    public static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Scroll Detector View Modifier
public struct DetectScrollModifier: ViewModifier {
    @State private var lastOffset: CGFloat = 0
    @State private var accumulatedScroll: CGFloat = 0
    
    public func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geo in
                    let offset = geo.frame(in: .named("scroll")).minY
                    Color.clear
                        .preference(key: ScrollOffsetPreferenceKey.self, value: offset)
                }
            )
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { offset in
                let delta = offset - lastOffset
                
                // If we are close to the top of the scrollview, always show/expand tab bar
                if offset > -25 {
                    ThemeManager.shared.setTabBarExpanded(true)
                    accumulatedScroll = 0
                } else {
                    // Accumulate scrolls to prevent micro-adjustments/jitter
                    accumulatedScroll += delta
                    
                    if accumulatedScroll < -15 {
                        // User scrolled down enough to collapse
                        ThemeManager.shared.setTabBarExpanded(false)
                        accumulatedScroll = 0
                    } else if accumulatedScroll > 15 {
                        // User scrolled up enough to expand
                        ThemeManager.shared.setTabBarExpanded(true)
                        accumulatedScroll = 0
                    }
                }
                
                lastOffset = offset
            }
    }
}

extension View {
    public func detectScroll() -> some View {
        self.modifier(DetectScrollModifier())
    }
}

// MARK: - Liquid Draggable Card View Modifier
public struct LiquidDraggableCardModifier: ViewModifier {
    public var isCompleted: Bool
    public var onComplete: () -> Void
    
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging: Bool = false
    
    public func body(content: Content) -> some View {
        let maxDrag: CGFloat = 130.0
        let progress = min(max(dragOffset, 0) / maxDrag, 1.0)
        let isDark = ThemeManager.shared.isDark
        
        content
            .background(
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        // Liquid Wave Fill Background
                        if progress > 0 && !isCompleted {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            ThemeManager.shared.activeAccent.opacity(0.24),
                                            ThemeManager.shared.activeAccent.opacity(0.06)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geo.size.width * progress)
                                .blur(radius: 1.5)
                        }
                    }
                }
            )
            // Liquid stretching dynamics (gets thin/thick and slants in motion)
            .scaleEffect(
                x: isDragging ? 1.0 - (progress * 0.08) : 1.0,
                y: isDragging ? 1.0 + (progress * 0.04) : 1.0,
                anchor: .leading
            )
            .rotationEffect(.degrees(Double(dragOffset / 20.0)), anchor: .center)
            .offset(x: dragOffset)
            .gesture(
                DragGesture(minimumDistance: 8)
                    .onChanged { value in
                        if !isCompleted {
                            isDragging = true
                            if value.translation.width > 0 {
                                // Add liquid stretch friction past limit
                                if value.translation.width > maxDrag {
                                    dragOffset = maxDrag + (value.translation.width - maxDrag) * 0.2
                                } else {
                                    dragOffset = value.translation.width
                                }
                            } else {
                                dragOffset = value.translation.width * 0.25
                            }
                            
                            if Int(dragOffset) % 15 == 0 {
                                AppHapticFeedback.lightImpact()
                            }
                        }
                    }
                    .onEnded { value in
                        isDragging = false
                        if dragOffset >= maxDrag && !isCompleted {
                            AppHapticFeedback.heavyImpact()
                            onComplete()
                            withAnimation(.spring(response: 0.32, dampingFraction: 0.72)) {
                                dragOffset = 0
                            }
                        } else {
                            withAnimation(.spring(response: 0.38, dampingFraction: 0.65)) {
                                dragOffset = 0
                            }
                        }
                    }
            )
    }
}

extension View {
    public func liquidDraggable(isCompleted: Bool, onComplete: @escaping () -> Void) -> some View {
        self.modifier(LiquidDraggableCardModifier(isCompleted: isCompleted, onComplete: onComplete))
    }
}

// MARK: - Liquid Glass Progress Bar
public struct LiquidProgressBar: View {
    public var value: Double // 0.0 to 1.0
    
    public init(value: Double) {
        self.value = value
    }
    
    public var body: some View {
        let isDark = ThemeManager.shared.isDark
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                // Trough background: Frosty glass
                Capsule()
                    .fill(Color.white.opacity(isDark ? 0.06 : 0.12))
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(isDark ? 0.08 : 0.20), lineWidth: 1.0)
                    )
                    .shadow(color: Color.black.opacity(isDark ? 0.20 : 0.04), radius: 2, x: 0, y: 1)
                
                // Track fill: Liquid Gradient
                if value > 0 {
                    let fillWidth = geo.size.width * CGFloat(value)
                    
                    ZStack(alignment: .trailing) {
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: ThemeManager.shared.activeGradient,
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        // Specular lighting sheen inside the liquid
                        GeometryReader { fillGeo in
                            let gradient = LinearGradient(
                                colors: [
                                    Color.white.opacity(0.35),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            Path { path in
                                path.move(to: CGPoint(x: 0, y: 0))
                                path.addLine(to: CGPoint(x: fillGeo.size.width, y: 0))
                                path.addQuadCurve(
                                    to: CGPoint(x: 0, y: fillGeo.size.height * 0.45),
                                    control: CGPoint(x: fillGeo.size.width * 0.25, y: fillGeo.size.height * 0.1)
                                )
                                path.closeSubpath()
                            }
                            .fill(gradient)
                        }
                        .clipShape(Capsule())
                        
                        // Glowing leading bead/droplet at the edge of progress
                        Circle()
                            .fill(Color.white)
                            .frame(width: 14, height: 14)
                            .shadow(color: ThemeManager.shared.activeAccent, radius: 4, x: 0, y: 0)
                            .offset(x: 3) // overlap slightly
                    }
                    .frame(width: fillWidth)
                    .transition(.opacity.combined(with: .scale(scale: 0.8, anchor: .leading)))
                }
            }
        }
        .frame(height: 12)
    }
}

// MARK: - Liquid Scrubber Bar (Interactive Progress Slider)
public struct LiquidScrubberBar: View {
    public var value: Double // 0.0 to 1.0
    public var onSeek: (Double) -> Void
    
    @State private var dragProgress: Double? = nil
    
    public init(value: Double, onSeek: @escaping (Double) -> Void) {
        self.value = value
        self.onSeek = onSeek
    }
    
    public var body: some View {
        let isDark = ThemeManager.shared.isDark
        let currentVal = dragProgress ?? value
        
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                // Trough background
                Capsule()
                    .fill(Color.white.opacity(isDark ? 0.06 : 0.12))
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(isDark ? 0.08 : 0.20), lineWidth: 1.0)
                    )
                
                // Track fill
                if currentVal > 0 {
                    let fillWidth = geo.size.width * CGFloat(currentVal)
                    
                    ZStack(alignment: .trailing) {
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: ThemeManager.shared.activeGradient,
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        // Specular sheen highlight
                        GeometryReader { fillGeo in
                            let gradient = LinearGradient(
                                colors: [
                                    Color.white.opacity(0.35),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            Path { path in
                                path.move(to: CGPoint(x: 0, y: 0))
                                path.addLine(to: CGPoint(x: fillGeo.size.width, y: 0))
                                path.addQuadCurve(
                                    to: CGPoint(x: 0, y: fillGeo.size.height * 0.45),
                                    control: CGPoint(x: fillGeo.size.width * 0.25, y: fillGeo.size.height * 0.1)
                                )
                                path.closeSubpath()
                            }
                            .fill(gradient)
                        }
                        .clipShape(Capsule())
                        
                        // Glowing drag handle bead
                        Circle()
                            .fill(Color.white)
                            .frame(width: 14, height: 14)
                            .shadow(color: ThemeManager.shared.activeAccent, radius: 4, x: 0, y: 0)
                            .offset(x: 3)
                    }
                    .frame(width: fillWidth)
                }
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { val in
                        let percent = Double(val.location.x / geo.size.width)
                        let clamped = min(max(percent, 0.0), 1.0)
                        dragProgress = clamped
                        if Int(val.location.x) % 20 == 0 {
                            AppHapticFeedback.lightImpact()
                        }
                    }
                    .onEnded { val in
                        if let finalProgress = dragProgress {
                            AppHapticFeedback.mediumImpact()
                            onSeek(finalProgress)
                        }
                        dragProgress = nil
                    }
            )
        }
        .frame(height: 12)
    }
}
