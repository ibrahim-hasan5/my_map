<div align="center">

# 📍 Real-Time Location Tracker

<img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
<img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" />
<img src="https://img.shields.io/badge/Google%20Maps-4285F4?style=for-the-badge&logo=google-maps&logoColor=white" />
<img src="https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white" />

[![Build & Release APK](https://github.com/ibrahim-hasan5/my_map/actions/workflows/build_release.yml/badge.svg)](https://github.com/ibrahim-hasan5/my_map/actions/workflows/build_release.yml)
[![GitHub release](https://img.shields.io/github/v/release/ibrahim-hasan5/my_map?color=blue&label=Latest%20Release)](https://github.com/ibrahim-hasan5/my_map/releases/latest)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

> A Flutter application that tracks real-time GPS location, draws polylines on Google Maps, and displays live coordinate information — built as a university assignment on Google Maps & Geolocator integration.

[📥 Download APK](#-download--install) • [✨ Features](#-features) • [🚀 Getting Started](#-getting-started) • [🏗️ CI/CD Pipeline](#️-cicd-pipeline)

</div>

---

## 📸 Screenshots

| Map View | Marker Info Window |
|:---:|:---:|
| ![Map View](assets/screenshots/map_view.png) | ![Info Window](assets/screenshots/info_window.png) |
| Real-time location on Google Maps | Tap marker to see coordinates |

> *(Screenshots from the sample assignment — app displays live GPS data on a real device)*

---

## ✨ Features

| Feature | Description |
|---------|-------------|
| 🗺️ **Animated Map** | Camera smoothly animates to user's current GPS location on launch |
| 📍 **Real-Time Tracking** | Fetches and updates location every **10 seconds** automatically |
| 🔵 **Polyline Drawing** | Draws a connected blue polyline path as the user moves |
| 💬 **Info Window** | Tap the red marker to see **"My current location"** with lat/lng |
| 🔄 **Manual Refresh** | Floating refresh button for instant on-demand location update |
| 📊 **Live Status Card** | Bottom card displays real-time coordinates and tracking point count |

---

## 🏗️ Tech Stack

```
📦 Flutter (Dart)
├── 🗺  google_maps_flutter  ^2.9.0   → Google Maps rendering
├── 📡  geolocator           ^13.0.2  → GPS location access
└── 🎨  Material Design 3            → UI components
```

---

## 🚀 Getting Started

### Prerequisites

Before running this project, make sure you have:

- ✅ [Flutter SDK](https://docs.flutter.dev/get-started/install) installed (`flutter --version`)
- ✅ Android Studio or VS Code with Flutter extension
- ✅ An Android device or emulator
- ✅ A valid [Google Maps API Key](https://console.cloud.google.com/)

### 1️⃣ Clone the Repository

```bash
git clone https://github.com/ibrahim-hasan5/my_map.git
cd my_map
```

### 2️⃣ Install Dependencies

```bash
flutter pub get
```

### 3️⃣ Configure Your API Key

The Google Maps API Key is set in two places:

**Android** — [`android/app/src/main/AndroidManifest.xml`](android/app/src/main/AndroidManifest.xml)
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_API_KEY_HERE"/>
```

**Web** — [`web/index.html`](web/index.html)
```html
<script src="https://maps.googleapis.com/maps/api/js?key=YOUR_API_KEY_HERE&callback=googleMapsReady" async defer></script>
```

> ⚠️ **Required APIs** to enable in [Google Cloud Console](https://console.cloud.google.com/):
> - Maps SDK for Android
> - Maps JavaScript API (for web)
> - Geolocation API

### 4️⃣ Run the App

```bash
# Run on connected Android device (recommended for GPS accuracy)
flutter run

# Run on Chrome (uses IP-based location approximation)
flutter run -d chrome

# Build release APK
flutter build apk --release
```

---

## 📥 Download & Install

> 🤖 APK is automatically built via GitHub Actions on every push to `master`.

1. Go to [**Releases**](https://github.com/ibrahim-hasan5/my_map/releases/latest)
2. Download `RealTimeLocationTracker-vX.X.X.apk`
3. On your Android phone:
   - Go to **Settings → Security → Install Unknown Apps**
   - Enable installation from your browser/file manager
4. Open the downloaded APK and install
5. Grant **Location Permission** when prompted

---

## 📂 Project Structure

```
my_map/
├── lib/
│   └── main.dart                  # Main app — all map & location logic
├── android/
│   └── app/src/main/
│       └── AndroidManifest.xml    # Location permissions + Maps API key
├── web/
│   └── index.html                 # Maps JS API script for web
├── .github/
│   └── workflows/
│       └── build_release.yml      # CI/CD — auto-build & release APK
└── pubspec.yaml                   # Dependencies
```

---

## 🏗️ CI/CD Pipeline

This project uses **GitHub Actions** for automated building and releasing.

```
Push to master
      │
      ▼
┌─────────────────────────────────┐
│   🐦 Setup Flutter (stable)     │
│   ☕ Setup Java 17               │
│   📦 flutter pub get            │
│   🔎 flutter analyze            │
│   🏗️  flutter build apk --release│
│   🎉 Create GitHub Release      │
│   📎 Attach APK to Release      │
└─────────────────────────────────┘
      │
      ▼
 📥 APK available in Releases tab
```

[![Build & Release APK](https://github.com/ibrahim-hasan5/my_map/actions/workflows/build_release.yml/badge.svg)](https://github.com/ibrahim-hasan5/my_map/actions/workflows/build_release.yml)

---

## 🔑 Required Permissions

| Permission | Purpose |
|------------|---------|
| `ACCESS_FINE_LOCATION` | Precise GPS location |
| `ACCESS_COARSE_LOCATION` | Approximate network location |
| `INTERNET` | Load Google Maps tiles & API |

---

## ⚠️ Known Limitations

| Platform | Location Accuracy |
|----------|------------------|
| 📱 **Android** | ✅ Full GPS accuracy — recommended |
| 🌐 **Web (Chrome)** | ⚠️ IP/WiFi-based approximation — less accurate on desktop |

> **Note:** For accurate real-time tracking with polylines, always test on a **physical Android device** with GPS enabled.

---

## 📚 Assignment Context

This project was built as a **university assignment** covering:

- ✅ Google Maps Flutter integration
- ✅ Geolocator for real-time GPS tracking
- ✅ Marker with InfoWindow
- ✅ Polyline drawing between location points
- ✅ Camera animation to current location
- ✅ CI/CD pipeline with GitHub Actions

**Course Topic:** Google Maps & Geolocator in Flutter

---

## 🤝 Contributing

Contributions are welcome! Feel free to open an issue or submit a pull request.

1. Fork the project
2. Create your feature branch: `git checkout -b feature/AmazingFeature`
3. Commit your changes: `git commit -m 'Add some AmazingFeature'`
4. Push to the branch: `git push origin feature/AmazingFeature`
5. Open a Pull Request

---

## 📄 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

<div align="center">

**Made with ❤️ using Flutter & Google Maps**

⭐ Star this repo if you found it helpful!

</div>
