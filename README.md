# WreckerLogix

**AI-Powered Tow Industry Operations Platform**

WreckerLogix is a comprehensive mobile and desktop application built for the towing and recovery industry. It streamlines dispatch operations, driver management, documentation, and accounting into a single intelligent platform.

---

## Tech Stack

| Layer | Technology |
|-------|------------|
| Framework | Flutter (Dart) |
| Platforms | iOS, Android, Windows, macOS, Linux, Web |
| State Management | Provider |
| Routing | GoRouter |
| Backend | Firebase (Auth, Firestore, Storage) |
| GPS | Geolocator + Google Maps |
| Voice | speech_to_text + flutter_tts |
| Camera | image_picker |

> **Why Flutter?** Single codebase for mobile AND desktop. Office staff use Windows desktops while drivers use phones — Flutter handles both from one codebase with native performance.

---

## Core Modules

### 🚛 Dispatch Workflow (`lib/features/dispatch/`)
- Job creation with full customer/vehicle details
- Driver assignment and status tracking (Pending → Assigned → En Route → On Scene → In Progress → Completed)
- Priority queue management (Low, Normal, High, Emergency)
- Support for 10 service types (Flatbed, Heavy Duty, Winch Out, Lockout, etc.)

### 🎤 Voice Command Engine (`lib/features/voice_commands/`)
- Hands-free operation for drivers
- Natural language job status updates ("en route", "on scene", "completed")
- Voice-activated camera and dispatch calls
- Text-to-speech feedback

### 📍 GPS Fleet Tracking (`lib/features/gps/`)
- Real-time fleet vehicle positions
- Driver status monitoring (Available, En Route, On Scene, Busy, Offline)
- Speed and heading tracking
- Google Maps integration ready

### 📸 Photo Documentation (`lib/features/photo_docs/`)
- Vehicle condition capture (Before Pickup, Damage, After Drop-off, Scene)
- Geotagged and timestamped photos
- Per-job photo organization

### ⏱️ Time Tracking (`lib/features/time_tracking/`)
- Clock in/out with one tap
- Break management
- Automatic overtime calculation (8+ hours)
- Weekly hour summaries

### 💰 Accounting (`lib/features/accounting/`)
- Invoice generation with line items
- Tax calculation
- Payment tracking (Cash, Check, Credit Card, ACH)
- Revenue and outstanding balance dashboards

---

## Project Structure

```
Wreckerlogix/
├── lib/
│   ├── main.dart                          # App entry point
│   ├── core/
│   │   ├── router/app_router.dart         # GoRouter navigation
│   │   ├── screens/                       # Dashboard & Login
│   │   ├── services/auth_service.dart     # Authentication
│   │   └── theme/app_theme.dart           # Light/dark themes
│   └── features/
│       ├── dispatch/                      # Dispatch module
│       │   ├── models/job.dart
│       │   ├── providers/dispatch_provider.dart
│       │   └── screens/                   # List, Detail, Create
│       ├── gps/                           # GPS tracking module
│       │   ├── models/fleet_vehicle.dart
│       │   ├── providers/gps_provider.dart
│       │   └── screens/gps_screen.dart
│       ├── voice_commands/                # Voice command module
│       │   ├── models/voice_command.dart
│       │   ├── providers/voice_command_provider.dart
│       │   └── screens/voice_command_screen.dart
│       ├── photo_docs/                    # Photo documentation
│       │   ├── models/photo_doc.dart
│       │   ├── providers/photo_doc_provider.dart
│       │   └── screens/photo_doc_screen.dart
│       ├── time_tracking/                 # Time tracking module
│       │   ├── models/time_entry.dart
│       │   ├── providers/time_tracking_provider.dart
│       │   └── screens/time_tracking_screen.dart
│       └── accounting/                    # Accounting module
│           ├── models/invoice.dart
│           ├── providers/accounting_provider.dart
│           └── screens/                   # Dashboard, Create Invoice
├── test/providers_test.dart               # Unit tests
├── assets/icons/wreckerlogix_icon.svg     # App icon
├── pubspec.yaml                           # Dependencies
├── analysis_options.yaml                  # Lint rules
└── .github/workflows/
    ├── ci.yml                             # CI: analyze, test, format
    └── release.yml                        # Build: Android, iOS, Web, Desktop
```

---

## Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.24+ stable)
- Dart SDK (bundled with Flutter)
- Android Studio or VS Code with Flutter extension
- Xcode (for iOS builds, macOS only)

### Setup
```bash
# Clone the repository
git clone https://github.com/mward5710-byte/Wreckerlogix.git
cd Wreckerlogix

# Install dependencies
flutter pub get

# Run on connected device or emulator
flutter run

# Run on specific platforms
flutter run -d android
flutter run -d ios
flutter run -d chrome        # Web
flutter run -d windows
flutter run -d macos
flutter run -d linux
```

### Running Tests
```bash
flutter test
```

### Building for Release
```bash
# Android APK
flutter build apk --release

# Android App Bundle (for Play Store)
flutter build appbundle --release

# iOS (requires Xcode)
flutter build ios --release

# Web
flutter build web --release

# Desktop
flutter build windows --release
flutter build macos --release
flutter build linux --release
```

---

## CI/CD

GitHub Actions workflows are configured for:
- **CI** (`ci.yml`): Runs on every push/PR — analyzes code, runs tests, checks formatting
- **Release** (`release.yml`): Triggered by version tags (`v*`) — builds APK, AAB, iOS, Web, Linux, Windows, macOS and uploads artifacts

---

## License

Proprietary — All rights reserved.
