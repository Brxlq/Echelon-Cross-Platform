# Echelon

Echelon is a premium Flutter car-sharing demo app built to showcase modern mobile UI, deep linking, URL routing, and cloud-backed state.

The project combines a polished fleet discovery experience with booking flows, user profiles, in-app support chat, favorites, and both local and Firebase-backed persistence.

---

## App Overview

Echelon is designed as a high-quality vehicle rental experience with the following capabilities:

- Fleet discovery with filter chips, categories, and search suggestions
- Tabbed car classes for Economy, Comfort, Premium, and Electric vehicles
- Vehicle detail pages with hero animations, add-on selection, and booking controls
- Booking and reservation flow using draggable bottom sheets and modal panels
- User authentication with Firebase Auth
- Favorites syncing through Firestore or an in-memory fallback repository
- Local caching for theme mode, color selection, and last active tab
- Support chat and fallback handling for unavailable vehicles
- Deep link routing using `go_router`

---

## Key Features

- `go_router` route-based navigation with nested routes and readable URLs
- Firebase integration for auth, Firestore favorites, and optional storage support
- Local persistence using `shared_preferences` and `drift` / `sqlite3_flutter_libs`
- Responsive Material 3 UI with custom theme seed and adaptive dark mode
- Animated transitions, hero effects, and a smooth mobile-first booking interface
- Offline-capable demo mode via `InMemoryFavouriteVehicleRepository`
- Modern input patterns: `SearchAnchor`, `SearchBar`, `FilterChip`, `SegmentedButton`

---

## Tech Stack

- Flutter SDK `>=3.0.5 <4.0.0`
- `go_router` for declarative routing and deep-link support
- `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`
- `shared_preferences` for simple local settings and state caching
- `drift` + `sqlite3_flutter_libs` for local database storage
- `http` for network calls and API fallback handling
- `url_launcher` for external URI intents and web URL actions
- `image_picker` and `lottie` for richer media experiences

---

## Routes and Deep Links

The app uses route-based navigation, including nested paths that match vehicle detail and support screens.

Example routes:

- `/login` — authentication screen
- `/:tab` — home tab view for Discover, Favorites, Orders, Profile, etc.
- `/:tab/vehicle/:id` — deep link into a specific vehicle detail page
- `/:tab/support-chat` — support chat screen

This routing design enables clean link handling, easy sharable URLs, and predictable navigation.

---

## Getting Started

### Prerequisites

- Flutter SDK installed
- Android Studio, Xcode, or web/browser tooling configured for Flutter
- Optional: Firebase project configured for Android / iOS / web

### Install dependencies

```bash
flutter pub get
```

### Run the app

```bash
flutter run
```

### Run tests

```bash
flutter test
```

---

## Firebase Support

Firebase is initialized in `lib/main.dart` and is optional during local development. If Firebase is not configured, the app still starts with a caching fallback.

To enable Firebase fully:

1. Add your Firebase config files for Android (`google-services.json`) and iOS (`GoogleService-Info.plist`)
2. Ensure `firebase_options.dart` is generated for your project
3. Run the app again

---

## Project Structure

- `lib/main.dart` — app entry point and router setup
- `lib/home.dart` — main home shell with tabs and shared app state
- `lib/screens/` — page screens for vehicles, profile, orders, chat, and login
- `lib/components/` — reusable UI widgets and cards
- `lib/favourites/` — favorites repository, manager, and models
- `lib/local/` — local database and cache helpers
- `lib/network/` — remote API helpers and vehicle catalog service
- `lib/models/` — shared data models across the app
- `assets/` — images, animations, categories, and mock data

---

## Notes

- This project is structured as a cross-platform Flutter app with Android, iOS, and web support.
- The app is a demo and uses both real Firebase connections and local fallback logic for easier development.
- The UI emphasizes a premium fleet rental experience with polished animations and material design patterns.

---

## 📝 License

This repository is intended as a personal demo project. Use and adapt it freely for learning and portfolio purposes.
