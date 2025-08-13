# PassKeeper 🛡️

![Build Status](https://img.shields.io/badge/build-passing-brightgreen)
![License](https://img.shields.io/badge/license-MIT-blue)
![Flutter Version](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)

A secure, offline-first password manager built with Flutter. PassKeeper allows you to store and organize all your account credentials locally on your device, protected by strong encryption and your master password.

---

## ✨ Key Features

### 🔐 Security & Encryption
* **100% Offline:** All data is stored locally on your device in a secure SQLite database. Your data never leaves your phone.
* **End-to-End Encryption:** All sensitive account information (especially passwords) is encrypted using the powerful **AES-256** algorithm.
* **Zero Knowledge Model:** Your master password is **hashed** for verification and is **never stored**. It's the key to unlock your vault and exists only in your memory.
* **Session-Based Security:** The encryption key is derived from your master password only when you need it and is cleared from memory when the app is closed.
* **Biometric App Lock:** Use your device's fingerprint or Face ID for quick and convenient access to the app.
* **Customizable Auto-Lock Timer:** For added security, the app automatically locks the vault if left in the background. The timer duration is fully customizable by the user.
* **Permanent Data Deletion:** Securely delete your entire user profile and all associated data with master password confirmation.

### 🗂️ Organization & Management
* **Custom Categories:** Create, edit, and delete your own custom categories.
* **Multi-Select & Batch Delete:** Easily select multiple categories at once to delete them in a single action.
* **Drag & Drop Reordering:** Intuitively reorder accounts *within* their category and reorder entire categories on the management screen.
* **Full Account CRUD:** Create, view, edit, and delete account credentials with an intuitive UI.
* **Real-time Search:** Instantly find any account by searching for its service name or username.
* **Slidable Actions:** Quickly edit or delete accounts with modern swipe gestures.
* **Password Generator:** Create strong, unique, and customizable passwords directly within the app.
* **Password Strength Meter:** Get real-time feedback on the strength of your passwords as you type.

### 🎨 Personalization & Accessibility
* **Adaptive Theming:** The entire app is beautifully themed. Users can manually switch between **Light**, **Dark**, and **System default** themes from the settings screen for a personalized visual experience.
* **Full Localization (i18n):** Complete support for both **English** and **Arabic**, including Right-to-Left (RTL) layouts. The app automatically detects the device language but allows the user to manually override it.

### 🔄 Data Portability
* **Export to Excel:** Securely back up your vault by exporting it to an organized Excel (`.xlsx`) file. Passwords are **decrypted** for this export to ensure the backup is readable.
* **Import from Excel:** Easily restore your data from a backup file. Passwords from the file are **re-encrypted** on import with your current master password.

---

## 🛠️ Tech Stack & Architecture

* **Framework:** Flutter
* **State Management:** BLoC / Cubit (`flutter_bloc`)
* **Database:** SQLite (`sqflite`)
* **Local Storage:** `shared_preferences` for session and settings.
* **Cryptography:** `encrypt` & `crypto` for AES encryption and SHA-256 hashing.
* **Key Packages:**
    * `local_auth` for biometric authentication.
    * `flutter_slidable` for swipe actions.
    * `excel`, `file_picker`, `share_plus` for data import/export.
    * `flutter_animate` & `animated_text_kit` for animations.
    * `google_fonts` for typography.
    * `flutter_svg` for scalable illustrations.
    * `collection` for advanced data manipulation.

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

## 🗺️ Future Roadmap

Here are some planned features to make PassKeeper even better:

-   [ ] **Comprehensive Testing:** Add Unit, Widget, and Integration tests.
-   [ ] **Tablet/Desktop Layouts:** Create a responsive UI for larger screens.
-   [ ] **Favorites System:** Mark important accounts for quick access.

---

## 📄 License

Distributed under the MIT License.

---

## 👤 Contact

Mohammed Nour Shkeir - [@shkeir_nou55392](https://twitter.com/shkeir_nou55392) - mohammednourshkeir@gmail.com

Project Link: [https://github.com/NourShkeir212/passkeeper](https://github.com/NourShkeir212/passkeeper)