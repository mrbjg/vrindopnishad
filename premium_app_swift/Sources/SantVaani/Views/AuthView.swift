import SwiftUI

public struct AuthView: View {
    @State private var isLogin = true
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    
    let onAuthSuccess: () -> Void
    
    public var body: some View {
        ZStack {
            PremiumUI.masterBackground()
            
            VStack(spacing: 24) {
                Spacer()
                
                // Logo & Welcome Title
                VStack(spacing: 8) {
                    Text("ॐ")
                        .font(.system(size: 64, weight: .bold))
                        .foregroundColor(ThemeManager.shared.activeAccent)
                        .evolvingAura(color: ThemeManager.shared.activeAccent, intensity: 1.0)
                    
                    Text("संत-वाणी प्रीमियम")
                        .font(PremiumFonts.display(size: 26, weight: .black))
                        .foregroundColor(ThemeManager.shared.textPrimary)
                    
                    Text("दिव्य भक्ति और साधना मंच")
                        .font(PremiumFonts.sans(size: 14))
                        .foregroundColor(ThemeManager.shared.textMuted)
                }
                .padding(.bottom, 20)
                
                // Form Container
                VStack(spacing: 16) {
                    if !isLogin {
                        TextField("नाम (Name)", text: $name)
                            .padding()
                            .background(ThemeManager.shared.surfaceColor)
                            .cornerRadius(12)
                            .foregroundColor(ThemeManager.shared.textPrimary)
                    }
                    
                    TextField("ईमेल (Email)", text: $email)
                        #if os(iOS)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        #endif
                        .padding()
                        .background(ThemeManager.shared.surfaceColor)
                        .cornerRadius(12)
                        .foregroundColor(ThemeManager.shared.textPrimary)
                    
                    SecureField("पासवर्ड (Password)", text: $password)
                        .padding()
                        .background(ThemeManager.shared.surfaceColor)
                        .cornerRadius(12)
                        .foregroundColor(ThemeManager.shared.textPrimary)
                    
                    Button(action: {
                        AppHapticFeedback.heavyImpact()
                        onAuthSuccess()
                    }) {
                        Text(isLogin ? "लॉगिन करें" : "पंजीकरण करें")
                            .font(PremiumFonts.sans(size: 15, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(ThemeManager.shared.activeAccent)
                            .cornerRadius(12)
                            .shadow(color: ThemeManager.shared.activeAccent.opacity(0.3), radius: 6, x: 0, y: 3)
                    }
                    .disabled(email.isEmpty || password.isEmpty)
                }
                .padding()
                .glassCard(borderRadius: 24)
                .padding(.horizontal, 20)
                
                // Social Identity Logins
                VStack(spacing: 12) {
                    Text("या इनके माध्यम से जुड़ें")
                        .font(PremiumFonts.sans(size: 12))
                        .foregroundColor(ThemeManager.shared.textMuted)
                    
                    HStack(spacing: 20) {
                        Button(action: {
                            AppHapticFeedback.mediumImpact()
                            onAuthSuccess()
                        }) {
                            HStack {
                                Image(systemName: "apple.logo")
                                Text("Apple")
                            }
                            .font(PremiumFonts.sans(size: 13, weight: .semibold))
                            .foregroundColor(ThemeManager.shared.textPrimary)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .glassCard(borderRadius: 12)
                        }
                        
                        Button(action: {
                            AppHapticFeedback.mediumImpact()
                            onAuthSuccess()
                        }) {
                            HStack {
                                Image(systemName: "g.circle.fill")
                                Text("Google")
                            }
                            .font(PremiumFonts.sans(size: 13, weight: .semibold))
                            .foregroundColor(ThemeManager.shared.textPrimary)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .glassCard(borderRadius: 12)
                        }
                    }
                }
                
                Spacer()
                
                // Toggle Login/Register
                Button(action: {
                    AppHapticFeedback.lightImpact()
                    withAnimation {
                        isLogin.toggle()
                    }
                }) {
                    Text(isLogin ? "नया खाता बनाना चाहते हैं? रजिस्टर करें" : "पहले से खाता है? लॉगिन करें")
                        .font(PremiumFonts.sans(size: 13, weight: .bold))
                        .foregroundColor(ThemeManager.shared.activeAccent)
                }
                .padding(.bottom, 30)
            }
        }
    }
}
