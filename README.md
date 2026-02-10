# Dottr

**A personal markdown journal with a neo-brutalist soul.**

Dottr is a local-first journal app that stores entries as plain markdown files with YAML frontmatter. Your data stays on your device, syncs via Git on your terms.

<!-- TODO: Add screenshots -->

## Features

- **Markdown entries** with YAML frontmatter for structured metadata
- **Timeline view** with month grouping and quick navigation
- **Inline #tag detection** and tag browser
- **Custom property schemas** — define your own frontmatter fields
- **Entry templates** with frontmatter defaults
- **Full-text search** across all entries
- **"On This Day" memories** — surface past entries from the same date
- **Configurable reminders** with recurring notification schedules
- **Day One import** — migrate from Day One via JSON export
- **Dark mode** with accent color customization
- **Neo-brutalist UI** — bold borders, Space Grotesk + JetBrains Mono

## Install

### macOS

1. Download `dottr-macos.zip` from [Releases](../../releases/latest)
2. Extract and move `Dottr.app` to Applications
3. Right-click → **Open** (required once for unsigned apps)

### Android

1. Download `dottr-android.apk` from [Releases](../../releases/latest)
2. Open the APK to install (enable "Install from unknown sources" if prompted)

### iOS (build from source)

Requires Xcode and the Flutter SDK.

```sh
git clone https://github.com/nickel-otter/dottr.git
cd dottr
flutter pub get
flutter build ios
# Open ios/Runner.xcworkspace in Xcode, set your signing team, build & run
```

## Development

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable channel)
- Xcode (for macOS / iOS)
- Android Studio or Android SDK (for Android)

### Setup

```sh
git clone https://github.com/nickel-otter/dottr.git
cd dottr
flutter pub get
flutter run -d macos   # or: -d chrome, -d android
```

### Project Structure

```
lib/
├── app.dart                    # App root widget
├── main.dart                   # Entry point
├── router.dart                 # GoRouter navigation
├── core/
│   ├── config.dart             # App configuration
│   ├── constants.dart          # Shared constants
│   ├── theme/                  # Neo-brutalist theme system
│   └── utils/                  # Frontmatter parser, slugs, etc.
├── models/                     # Entry, Template, Schema, etc.
├── providers/                  # Riverpod state providers
├── services/                   # File I/O, Git, notifications, import
└── screens/                    # UI screens (timeline, editor, settings, ...)
```

### Architecture

- **Flutter** + **Riverpod** for reactive state management
- **GoRouter** for declarative navigation
- **File-based storage** — entries are `.md` files, settings are JSON
- **No backend** — everything runs locally, Git sync is opt-in

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for development workflow, code style, and PR guidelines.

## License

[MIT](LICENSE)
