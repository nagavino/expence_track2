# 💳 Premium Offline Expense Tracker

An ultra-modern, offline-first personal finance tracker built with Flutter. Featuring a state-of-the-art fintech UI/UX, glassmorphism design aesthetics, interactive charts, and highly optimized build sizes.

---

## ✨ Key Features

### 🔒 100% Offline-First Architecture
*   **Hive Local DB**: High-performance NoSQL local database storing all user transactions.
*   **Encrypted Session Storage**: Secure storage powered by `flutter_secure_storage` to handle login sessions locally.
*   **Zero External API Calls**: Guaranteed privacy, data security, and instant performance without internet dependencies.

### 🎨 Fintech Visual Design (Ultra-Promax UI/UX)
*   **Glassmorphic Floating Navigation**: Beautiful blurred bottom navigation bar using `BackdropFilter` and interactive active-tab pill animations.
*   **Swipe Gestures (Dual Actions)**:
    *   **Swipe Right-to-Left**: Deletes transaction entries with a safety-first confirmation dialog.
    *   **Swipe Left-to-Right**: Launches the editor to modify transactions instantly.
*   **Curated Gradients & Soft Shadows**: Indigo and purple gradient themes combined with premium drop shadows.

### 📈 Interactive Custom Analytics & Insights
*   **Curved Spline Area Chart**: Custom-painted vector curves displaying transaction trends.
*   **Interactive Inspection**: Tap or hover on any bar or point in the chart to inspect precise spending amounts.
*   **Multiple Timeframes**: Dynamically switch dashboard analysis between **Today**, **Weekly**, and **Monthly** reports.
*   **Category Distribution**: Detailed progress bars illustrating budget utilization across categories (Food, Travel, Bills, Shopping, etc.).

### ⚙️ Account & Budget Controls
*   **Persistent Monthly Budget Targets**: Set your target spending limit in the Settings tab, which is saved locally using `SharedPreferences` and dynamically updates progress bars across the app.
*   **Profile Overview & Local Logging**: Keep track of local databases and account credentials easily.

---

## ⚡ Build Size Optimizations

The application is highly optimized to run smoothly on low-end hardware and maintains a minimal installer file size:
*   **R8/ProGuard Minification**: Unused classes and resources are stripped automatically during compilation.
*   **Asset Compression**: Compressed default graphics by **91%** (reducing the logo asset from 1.14 MB to 101 KB).
*   **Icon Tree-Shaking**: Font files are tree-shaken, dropping material icon font sizes by **99.3%**.
*   **ABI Splitting**: Target-tailored builds for individual architectures.
    *   **ARM 64-bit APK**: `17.0 MB` (Modern phones)
    *   **ARM 32-bit APK**: `14.4 MB` (Older phones)

---

## 🚀 Getting Started

### Prerequisites
*   [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.7.2 or newer)
*   Android SDK

### Installation & Run

1.  Clone the repository:
    ```bash
    git clone https://github.com/nagavino/expence_track2.git
    cd expence_track2
    ```

2.  Install dependencies:
    ```bash
    flutter pub get
    ```

3.  Run the application on a connected device/emulator:
    ```bash
    flutter run --release
    ```

4.  Build the optimized production APKs:
    ```bash
    flutter build apk --release --split-per-abi --obfuscate --split-debug-info=build/app/outputs/symbols
    ```

---

## 🛠️ Technology Stack
*   **Core Framework**: Flutter (Dart)
*   **State Management**: Provider
*   **Local Databases**: Hive, SharedPreferences
*   **Secure Storage**: flutter_secure_storage
*   **Utility & Formatting**: Intl, Uuid, Crypto
