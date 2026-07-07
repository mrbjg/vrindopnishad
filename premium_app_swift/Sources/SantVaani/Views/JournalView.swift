import SwiftUI
import SwiftData

public struct JournalView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \JournalEntry.createdAt, order: .reverse) private var entries: [JournalEntry]
    
    @State private var showingAddSheet = false
    @State private var searchQuery = ""
    @State private var isMenuExpanded = false
    
    public var body: some View {
        ZStack {
            PremiumUI.masterBackground()
            
            VStack(spacing: 0) {
                // Header Add Button and Title
                HStack {
                    Text("आध्यात्मिक डायरी")
                        .font(PremiumFonts.display(size: 24, weight: .bold))
                        .foregroundColor(ThemeManager.shared.textPrimary)
                    
                    Spacer()
                    
                    if isMenuExpanded {
                        HStack(spacing: 12) {
                            Button(action: {
                                AppHapticFeedback.lightImpact()
                                showingAddSheet = true
                                withAnimation {
                                    isMenuExpanded = false
                                }
                            }) {
                                HStack(spacing: 4) {
                                    Text("🪷")
                                    Text("विचार")
                                        .font(PremiumFonts.sans(size: 11, weight: .bold))
                                }
                                .foregroundColor(ThemeManager.shared.textPrimary)
                            }
                            
                            Button(action: {
                                AppHapticFeedback.lightImpact()
                                logMeditation()
                                withAnimation {
                                    isMenuExpanded = false
                                }
                            }) {
                                HStack(spacing: 4) {
                                    Text("🧘")
                                    Text("ध्यान")
                                        .font(PremiumFonts.sans(size: 11, weight: .bold))
                                }
                                .foregroundColor(ThemeManager.shared.textPrimary)
                            }
                            
                            Button(action: {
                                AppHapticFeedback.lightImpact()
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    isMenuExpanded = false
                                }
                            }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(ThemeManager.shared.textMuted)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .glassCard(borderRadius: 16)
                        .transition(.asymmetric(insertion: .scale(scale: 0.8).combined(with: .opacity), removal: .scale(scale: 0.8).combined(with: .opacity)))
                    } else {
                        Button(action: {
                            AppHapticFeedback.mediumImpact()
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                isMenuExpanded = true
                            }
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(ThemeManager.shared.activeAccent)
                        }
                    }
                }
                .padding()
                
                // Search Reflections
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(ThemeManager.shared.textMuted)
                    
                    TextField("खोजें...", text: $searchQuery)
                        .foregroundColor(ThemeManager.shared.textPrimary)
                        .font(PremiumFonts.sans(size: 14))
                }
                .padding()
                .glassCard(borderRadius: 16)
                .padding(.horizontal)
                .padding(.bottom, 12)
                
                // Reflections List
                ScrollView {
                    LazyVStack(spacing: 16) {
                        Color.clear
                            .frame(height: 0)
                            .detectScroll()
                        
                        let filteredEntries = entries.filter { entry in
                            searchQuery.isEmpty || entry.title.contains(searchQuery) || entry.content.contains(searchQuery)
                        }
                        
                        if filteredEntries.isEmpty {
                            VStack(spacing: 12) {
                                Text("🪶")
                                    .font(.system(size: 40))
                                Text("कोई विचार नहीं मिला। आज की साधना और अनुभव यहाँ लिखें।")
                                    .font(PremiumFonts.sans(size: 13))
                                    .foregroundColor(ThemeManager.shared.textMuted)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                            .padding(.top, 100)
                        } else {
                            ForEach(filteredEntries) { entry in
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Text(entry.title)
                                            .font(PremiumFonts.sans(size: 16, weight: .bold))
                                            .foregroundColor(ThemeManager.shared.textPrimary)
                                        
                                        Spacer()
                                        
                                        if let phase = entry.moonPhase {
                                            Text(phase)
                                                .font(.system(size: 18))
                                        }
                                    }
                                    
                                    Text(entry.content)
                                        .font(PremiumFonts.sans(size: 13))
                                        .foregroundColor(ThemeManager.shared.textSecondary)
                                        .lineLimit(3)
                                        .lineSpacing(4)
                                    
                                    HStack {
                                        Text(formatDate(entry.createdAt))
                                            .font(PremiumFonts.sans(size: 11))
                                            .foregroundColor(ThemeManager.shared.textMuted)
                                        
                                        Spacer()
                                        
                                        Button(action: {
                                            AppHapticFeedback.lightImpact()
                                            modelContext.delete(entry)
                                        }) {
                                            Image(systemName: "trash")
                                                .font(.system(size: 12))
                                                .foregroundColor(Color.red.opacity(0.7))
                                        }
                                    }
                                }
                                .padding()
                                .glassCard(borderRadius: 20)
                            }
                        }
                    }
                    .padding()
                }
                .coordinateSpace(name: "scroll")
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddJournalEntryView { title, content, mood in
                let newEntry = JournalEntry(
                    id: UUID().uuidString,
                    firebaseUid: "local_user",
                    title: title,
                    content: content,
                    createdAt: Date(),
                    moonPhase: mood
                )
                modelContext.insert(newEntry)
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func logMeditation() {
        let newEntry = JournalEntry(
            id: UUID().uuidString,
            firebaseUid: "local_user",
            title: "🧘 ध्यान साधना लॉग",
            content: "आज सुबह ३० मिनट शांत चित्त होकर ध्यान साधना की। श्वास पर ध्यान केंद्रित करने से मन शांत और स्थिर महसूस हुआ।",
            createdAt: Date(),
            moonPhase: "🧘"
        )
        modelContext.insert(newEntry)
    }
}

// MARK: - Add Journal Entry Sheet View
struct AddJournalEntryView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var content = ""
    @State private var selectedMood = "🌅"
    
    let moods = ["🌅", "🪷", "🛕", "🕊️", "🏔️", "🧘"]
    let onSave: (String, String, String) -> Void
    
    var body: some View {
        NavigationStack {
            ZStack {
                ThemeManager.shared.scaffoldBg
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Mood selector
                    VStack(alignment: .leading, spacing: 8) {
                        Text("आज की भावना (Mood Rating)")
                            .font(PremiumFonts.sans(size: 13, weight: .bold))
                            .foregroundColor(ThemeManager.shared.textSecondary)
                        
                        HStack(spacing: 12) {
                            ForEach(moods, id: \.self) { mood in
                                Button(action: {
                                    AppHapticFeedback.lightImpact()
                                    selectedMood = mood
                                }) {
                                    Text(mood)
                                        .font(.system(size: 26))
                                        .padding(10)
                                        .background(selectedMood == mood ? ThemeManager.shared.activeAccent.opacity(0.2) : Color.clear)
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(selectedMood == mood ? ThemeManager.shared.activeAccent : Color.clear, lineWidth: 1.5)
                                        )
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    TextField("शीर्षक (Title)", text: $title)
                        .font(PremiumFonts.sans(size: 16, weight: .bold))
                        .padding()
                        .background(ThemeManager.shared.cardColor)
                        .cornerRadius(12)
                        .padding(.horizontal)
                    
                    TextEditor(text: $content)
                        .font(PremiumFonts.sans(size: 14))
                        .padding()
                        .background(ThemeManager.shared.cardColor)
                        .cornerRadius(12)
                        .padding(.horizontal)
                        .frame(minHeight: 200)
                    
                    Spacer()
                }
            }
            .navigationTitle("नया विचार लिखें")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("रद्द करें") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("सुरक्षित करें") {
                        if !title.isEmpty && !content.isEmpty {
                            onSave(title, content, selectedMood)
                            dismiss()
                        }
                    }
                    .disabled(title.isEmpty || content.isEmpty)
                }
            }
        }
    }
}
