# Sant-Vaani (Premium App)

Sant-Vaani is a premium spiritual and devotional platform built with Flutter. It provides users with a comprehensive set of tools for their spiritual journey, including chanting (Naam Jap), personal journaling, access to a vast library of spiritual content, and a sacred calendar for tracking important events.

## 🚀 Features

- **Naam Jap**: A digital counter for chanting and tracking mantra repetitions.
- **Spiritual Journal**: A private space for users to record their reflections and spiritual experiences.
- **Sacred Library**: A curated collection of wisdom, teachings (Vaani), and multimedia content.
- **Rituals & Daily Gyaan**: Daily wisdom and guided rituals for spiritual growth.
- **Sacred Calendar**: Track festivals, events, and important spiritual dates.
- **Audio Experience**: High-quality audio player for listening to devotional content with background playback support.
- **User Dashboard**: Personalized experience with progress tracking and daily challenges.
- **Admin Dashboard**: Comprehensive management interface for content and user analytics.

## 🛠️ Technology Stack

- **Framework**: [Flutter](https://flutter.dev/) (SDK ^3.11.1)
- **State Management**: [Riverpod](https://riverpod.dev/) for robust and reactive state control.
- **Backend Architecture**:
  - [Supabase](https://supabase.com/) for real-time database and storage.
  - [Firebase](https://firebase.google.com/) for Authentication (Google & Apple Sign-in) and Cloud Messaging.
- **Local Storage**: [SQLite (sqflite)](https://pub.dev/packages/sqflite) for offline data persistence and caching.
- **UI/UX Components**:
  - [Google Fonts](https://pub.dev/packages/google_fonts) for premium typography.
  - [Lottie](https://pub.dev/packages/lottie) and [Flutter Animate](https://pub.dev/packages/flutter_animate) for smooth micro-animations.
  - [Lucide Icons](https://pub.dev/packages/lucide_icons) & [Iconsax](https://pub.dev/packages/iconsax) for a modern, sleek interface.
  - [Cached Network Image](https://pub.dev/packages/cached_network_image) for efficient media loading.
- **Audio Engine**: [Just Audio](https://pub.dev/packages/just_audio) with background support.

## 🏗️ Architecture & Workflows

The project follows a **Feature-Based Clean Architecture** to ensure scalability and maintainability.

### 1. **Core Engines**
- **Spirituality Engine**: Manages the logic for spiritual activities (Jap, stats, and achievements).
- **Audio Service**: A centralized service for high-quality audio playback and playlist management.
- **Cache Service**: Handles offline data synchronization and local storage for a seamless experience.

### 2. **Key Workflows**
- **Authentication**: Secure login via Firebase/Supabase with social identity providers.
- **Content Delivery**: Dynamic content fetching from Supabase with local caching for offline accessibility.
- **Notifications**: Local and push notifications for reminders, events, and daily wisdom.

## 📂 Project Structure

```text
lib/
├── core/             # Base services, providers, design system, and utilities.
├── features/         # Feature-specific screens and logic (Auth, Home, Journal, etc.).
├── models/           # Data models (JournalEntry, Ritual, UserStats, etc.).
├── services/         # Third-party service integrations.
├── widgets/          # Shared UI components and layout elements.
└── main.dart         # App entry point with provider initialization.
```

## 📜 Dependencies

| Package | Purpose |
|---------|---------|
| `flutter_riverpod` | State Management |
| `supabase_flutter` | Database & Storage |
| `firebase_auth` | User Authentication |
| `just_audio` | Audio Playback |
| `sqflite` | Local Data Storage |
| `lottie` | Animations |
| `google_fonts` | Typography |

## 🚀 Getting Started

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Set up Firebase**:
   - Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS).

4. **Run the app**:
   ```bash
   flutter run
   ```

---
Built with ❤️ for the spiritual community.
