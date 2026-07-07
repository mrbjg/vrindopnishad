import SwiftUI

public struct MainNavigationView: View {
    @State private var selectedTab = 0
    @State private var themeManager = ThemeManager.shared
    @State private var isJapImmersive = false
    @State private var highlightScaleX: CGFloat = 1.0
    @State private var highlightScaleAnchor: UnitPoint = .center
    @State private var isKeyboardVisible = false
    @State private var isTransitioning = false
    @State private var isAIExpanded = false
    @Namespace private var tabNamespace
    
    public init() {
        #if canImport(UIKit)
        UITabBar.appearance().isHidden = true
        #endif
    }
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            // Active Tab View Content
            TabView(selection: $selectedTab) {
                HomeView()
                    .tag(0)
                
                LibraryView()
                    .tag(1)
                
                // Empty placeholder view for middle Jap Tab
                Color.clear
                    .tag(2)
                
                JournalView()
                    .tag(3)
                
                ProfileView()
                    .tag(4)
            }
            .ignoresSafeArea()
            
            // Intercept Jap Tab Selection
            if selectedTab == 2 {
                NaamJapView(isImmersiveParent: $isJapImmersive)
                    .transition(.opacity)
            }
            
            // MARK: - Floating Glassmorphic Bottom Navigation Bar
            if (!isJapImmersive || selectedTab != 2) && !isKeyboardVisible {
                HStack(spacing: 4) {
                    tabButton(index: 0, icon: "house", text: "गृह")
                    tabButton(index: 1, icon: "book", text: "संग्रह")
                    centerButton()
                    tabButton(index: 3, icon: "pencil.circle", text: "डायरी")
                    tabButton(index: 4, icon: "gearshape", text: "सेटिंग्स")
                }
                .padding(.horizontal, 10)
                .padding(.vertical, themeManager.isTabBarExpanded ? 8 : 4)
                .padding(.bottom, themeManager.isTabBarExpanded ? 22 : 10) // Safe area padding
                .background(
                    ZStack {
                        if themeManager.uiLiteEnabled {
                            RoundedRectangle(cornerRadius: 30)
                                .fill(themeManager.isDark ? Color(hex: 0xFF0E0E1A) : Color.white)
                        } else {
                            // 1. Dynamic Liquid Glass Lava-Lamp Background
                            LiquidGlassNavigationBackground()
                            
                            // 2. Sliding Mercury Liquid Glass Tab Selection Highlight (Pixel-Perfect HStack alignment)
                            HStack(spacing: 4) {
                                ForEach(0..<5) { index in
                                    ZStack {
                                        if selectedTab == index {
                                            LiquidGlassItemHighlight(isMoving: isTransitioning)
                                                .frame(height: themeManager.isTabBarExpanded ? 52.0 : 36.0)
                                                .opacity(index == 2 ? 0.0 : 1.0)
                                                .scaleEffect(x: highlightScaleX, y: 1.0, anchor: highlightScaleAnchor)
                                                .matchedGeometryEffect(id: "activeTabHighlight", in: tabNamespace)
                                        } else {
                                            // Invisible placeholder to reserve layout slot
                                            Color.clear
                                                .frame(height: themeManager.isTabBarExpanded ? 52.0 : 36.0)
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                            }
                            .padding(.horizontal, 10)
                            .padding(.bottom, themeManager.isTabBarExpanded ? 22 : 10) // Align to button vertical grid
                        }
                    }
                )
                .overlay(
                    // 5. Glossy Outer Border Highlight (Simulating 3D refraction)
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.4),
                                    Color.white.opacity(0.05),
                                    themeManager.activeAccent.opacity(0.35),
                                    Color.white.opacity(0.15)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.2
                        )
                )
                .shadow(color: Color.black.opacity(themeManager.isDark ? 0.35 : 0.06), radius: 16, x: 0, y: 6)
                .padding(.horizontal, 16)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            // MARK: - Satsang AI Floating Command Bar
            if (!isJapImmersive || selectedTab != 2) && !isKeyboardVisible && (selectedTab == 0 || selectedTab == 1 || isAIExpanded) {
                SatsangAIView(isExpanded: $isAIExpanded)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .onChange(of: selectedTab) { oldTab, newTab in
            let diff = newTab - oldTab
            guard diff != 0 else { return }
            
            // Determine stretching direction anchor
            highlightScaleAnchor = diff > 0 ? .leading : .trailing
            
            // Liquid mercury stretching morph
            withAnimation(.easeOut(duration: 0.14)) {
                highlightScaleX = 1.38
                isTransitioning = true
            }
            
            // Snap back cleanly on target arrival
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.14) {
                withAnimation(.spring(response: 0.30, dampingFraction: 0.60)) {
                    highlightScaleX = 1.0
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.32) {
                isTransitioning = false
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
            withAnimation(.easeOut(duration: 0.15)) {
                isKeyboardVisible = true
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            withAnimation(.easeIn(duration: 0.15)) {
                isKeyboardVisible = false
            }
        }
    }
    
    // Reusable view for each nav tab button with dynamic scroll sizing
    @ViewBuilder
    private func tabButton(index: Int, icon: String, text: String) -> some View {
        Button(action: {
            AppHapticFeedback.lightImpact()
            withAnimation(.spring(response: 0.32, dampingFraction: 0.78)) {
                selectedTab = index
            }
        }) {
            VStack(spacing: themeManager.isTabBarExpanded ? 4 : 0) {
                Image(systemName: selectedTab == index ? "\(icon).fill" : icon)
                    .font(.system(size: themeManager.isTabBarExpanded ? 20 : 18))
                    .foregroundColor(selectedTab == index ? themeManager.activeAccent : themeManager.textSecondary)
                    .frame(height: themeManager.isTabBarExpanded ? 24 : 32)
                
                if themeManager.isTabBarExpanded {
                    Text(text)
                        .font(PremiumFonts.sans(size: 10, weight: .bold))
                        .foregroundColor(selectedTab == index ? themeManager.activeAccent : themeManager.textSecondary)
                        .transition(.opacity.combined(with: .scale(scale: 0.8)))
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, themeManager.isTabBarExpanded ? 6 : 4)
        }
        .frame(maxWidth: .infinity)
    }
    
    // Dynamic Center Chanting Trigger Button
    @ViewBuilder
    private func centerButton() -> some View {
        Button(action: {
            AppHapticFeedback.heavyImpact()
            withAnimation(.spring(response: 0.32, dampingFraction: 0.78)) {
                selectedTab = 2
            }
        }) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: themeManager.activeGradient, startPoint: .top, endPoint: .bottom))
                    .frame(
                        width: themeManager.isTabBarExpanded ? 56 : 42,
                        height: themeManager.isTabBarExpanded ? 56 : 42
                    )
                    .shadow(color: themeManager.activeAccent.opacity(0.3), radius: 8, x: 0, y: 4)
                
                Text("ॐ")
                    .font(.system(size: themeManager.isTabBarExpanded ? 26 : 19, weight: .bold))
                    .foregroundColor(.white)
            }
            .offset(y: themeManager.isTabBarExpanded ? -14 : -4)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Selected Bottom Tab Item Highlight (Liquid Glass Style)
struct LiquidGlassItemHighlight: View {
    var isMoving: Bool
    
    var body: some View {
        let isDark = ThemeManager.shared.isDark
        ZStack {
            // Capsule base fill (Soft white glass in dark mode, soft black glass in light mode)
            Capsule()
                .fill(
                    isDark
                    ? Color.white.opacity(0.12)
                    : Color.black.opacity(0.06)
                )
            
            // Specular reflection sheen
            GeometryReader { geo in
                let gradient = LinearGradient(
                    colors: [
                        Color.white.opacity(isDark ? 0.20 : 0.40),
                        Color.clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                Path { path in
                    path.move(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: geo.size.width, y: 0))
                    path.addQuadCurve(
                        to: CGPoint(x: 0, y: geo.size.height * 0.45),
                        control: CGPoint(x: geo.size.width * 0.25, y: geo.size.height * 0.1)
                    )
                    path.closeSubpath()
                }
                .fill(gradient)
            }
        }
        .clipShape(Capsule())
        .overlay(
            ZStack {
                if isMoving {
                    // Chromatic Aberration Soap-Bubble Border during transition motion
                    Capsule()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.cyan.opacity(0.9),
                                    Color.purple.opacity(0.9),
                                    Color.yellow.opacity(0.9),
                                    Color.cyan.opacity(0.9)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2.0
                        )
                        .blur(radius: 0.8)
                } else {
                    // Clean White/Accent Refractive Edge when stationary
                    Capsule()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.55),
                                    Color.white.opacity(0.10),
                                    ThemeManager.shared.activeAccent.opacity(0.35),
                                    Color.white.opacity(0.20)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.2
                        )
                }
            }
        )
        .shadow(color: ThemeManager.shared.activeAccent.opacity(isMoving ? 0.25 : 0.08), radius: isMoving ? 6 : 3, x: 0, y: 1)
    }
}

// MARK: - Liquid Glass Navigation Background with Floating Lava-Lamp Orbs
struct LiquidGlassNavigationBackground: View {
    @State private var animateOrb1 = false
    @State private var animateOrb2 = false
    
    var body: some View {
        let isDark = ThemeManager.shared.isDark
        let activeAccent = ThemeManager.shared.activeAccent
        
        ZStack {
            // 1. Frosty Glass Base
            RoundedRectangle(cornerRadius: 30)
                .fill(.ultraThinMaterial.opacity(0.66))
            
            // 2. Slowly shifting liquid orbs (simulating morphing lava lamp inside the dock)
            GeometryReader { geo in
                ZStack {
                    // Accent Orb 1
                    Circle()
                        .fill(activeAccent.opacity(isDark ? 0.20 : 0.28))
                        .frame(width: geo.size.width * 0.45)
                        .blur(radius: 22)
                        .offset(
                            x: animateOrb1 ? geo.size.width * 0.18 : -geo.size.width * 0.18,
                            y: animateOrb1 ? 8 : -8
                        )
                        .animation(
                            .easeInOut(duration: 7.0)
                            .repeatForever(autoreverses: true),
                            value: animateOrb1
                        )
                    
                    // Highlighting White Orb 2
                    Circle()
                        .fill(Color.white.opacity(isDark ? 0.08 : 0.22))
                        .frame(width: geo.size.width * 0.35)
                        .blur(radius: 18)
                        .offset(
                            x: animateOrb2 ? -geo.size.width * 0.14 : geo.size.width * 0.14,
                            y: animateOrb2 ? -6 : 6
                        )
                        .animation(
                            .easeInOut(duration: 5.5)
                            .repeatForever(autoreverses: true),
                            value: animateOrb2
                        )
                }
                .onAppear {
                    animateOrb1 = true
                    animateOrb2 = true
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 30))
            
            // 3. Liquid depth reflection
            RoundedRectangle(cornerRadius: 30)
                .fill(LinearGradient(
                    colors: [
                        Color.white.opacity(isDark ? 0.08 : 0.20),
                        Color.clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
            
            // 4. Specular Sheen Path Overlay
            GeometryReader { geo in
                let gradient = LinearGradient(
                    colors: [
                        Color.white.opacity(isDark ? 0.12 : 0.25),
                        Color.clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                Path { path in
                    path.move(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: geo.size.width, y: 0))
                    path.addQuadCurve(
                        to: CGPoint(x: 0, y: geo.size.height * 0.40),
                        control: CGPoint(x: geo.size.width * 0.25, y: geo.size.height * 0.1)
                    )
                    path.closeSubpath()
                }
                .fill(gradient)
            }
        }
    }
}
