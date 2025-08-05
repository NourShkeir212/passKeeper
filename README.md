# PassKeeper 🛡️

![Build Status](https://img.shields.io/badge/build-passing-brightgreen)
![License](https://img.shields.io/badge/license-MIT-blue)
![Flutter Version](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)

A secure, offline-first password manager built with Flutter. PassKeeper allows you to store and organize all your account credentials locally on your device, protected by biometric authentication.

---

## ✨ Key Features

* **100% Offline:** All data is stored locally on your device using a SQLite database.
* **Secure Authentication:**
    * Local user sign-up and login.
    * Persistent sessions with a secure biometric (Fingerprint/Face ID) lock screen for returning users.
* **Account Management:**
    * Create, view, edit, and delete account credentials.
    * Store service names, usernames, passwords, recovery accounts, and phone numbers.
    * Copy credentials to the clipboard with a single tap.
* **Organization:**
    * Create and manage your own custom categories.
    * Accounts are automatically grouped by category on the home screen.
* **Modern UI & UX:**
    * Beautiful, modern design with both Light and Dark themes.
    * Smooth animations and transitions.
    * Intuitive swipe actions (slide-to-edit, slide-to-delete).
    * Real-time password validation during sign-up.
* **Data Portability:**
    * Export your entire vault to an organized Excel (`.xlsx`) file.
    * Import your vault from an Excel file to easily restore your data.
* **Powerful Settings:**
    * Manually switch between Light, Dark, and System themes.
    * Manually switch between English, Arabic, and System Language.
    * Enable or disable the biometric lock.
    * Change your master password.

---

## 🛠️ Tech Stack & Architecture

* **Framework:** Flutter
* **State Management:** BLoC / Cubit (`flutter_bloc`)
* **Database:** SQLite (`sqflite`)
* **Local Storage:** `shared_preferences` for session and settings management.
* **Architecture:**
    * Feature-first directory structure.
    * Clean separation of UI (Widgets), State Management (Cubits), and Business Logic (Services).
    * Reusable and theme-aware UI components.
* **Key Packages:**
    * `local_auth` for biometric authentication.
    * `flutter_slidable` for swipe actions.
    * `excel`, `file_picker`, `share_plus` for data import/export.
    * `flutter_animate` for beautiful animations.
    * `google_fonts` for modern typography.

---

## 🚀 Getting Started

To get a local copy up and running, follow these simple steps.

### Prerequisites

* Flutter SDK installed.
* An IDE like VS Code or Android Studio.

### Installation

1.  Clone the repo:
    ```sh
    git clone [https://github.com/NourShkeir212/passkeeper.git](https://github.com/NourShkeir212/passkeeper.git)
    ```
2.  Install packages:
    ```sh
    flutter pub get
    ```
3.  **Important:** Configure `local_auth` by following the setup instructions on [pub.dev](https://pub.dev/packages/local_auth) for `AndroidManifest.xml` (Android) and `Info.plist` (iOS).
4.  Run the app:
    ```sh
    flutter run
    ```

---

## 🗺️ Roadmap

Here are some planned features to make PassKeeper even better:

-   [ ] **Database Encryption:** Encrypt all sensitive data at rest.
-   [ ] **Password Generator:** A tool to create strong, random passwords.
-   [ ] **App Icon & Native Splash Screen:** Full branding for a professional feel.
-   [ ] **Enhanced Category Management:** Ability to edit and delete categories.
-   [ ] **Favorites System:** Mark important accounts for quick access.

---

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.

---

## 👤 Contact

Your Name - [@Mohammed Nour Shkeir](https://twitter.com/shkeir_nou55392) - mohammednourshkeir@gmail.com

Project Link: [https://github.com/NourShkeir212/passkeeper](https://github.com/NourShkeir212/passkeeper)
