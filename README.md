# TapPay — Fintech Mobile Client (Flutter)

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

TapPay is a responsive, production-ready fintech mobile client crafted in Flutter. It is designed and built based on the official [Figma Community Design](https://www.figma.com/design/bk4bA3ldr2bdRuk7xr6c1O5/TapPay--Community-?node-id=0-1&t=f8mMtG9MBlng915l-1). The project demonstrates clean architecture, native platform integration (Home Screen widgets & QR scanning), fintech-grade security hardening (app privacy shield, biometric authentication, secure keystore), and responsive UI layouts across mobile and tablet form factors.

---

## Table of Contents
1. [Core Features](#core-features)
2. [Architecture & Design Principles](#architecture--design-principles)
3. [Project Structure](#project-structure)
4. [Technology Stack & Package Choices](#technology-stack--package-choices)
5. [Native Platform Integration](#native-platform-integration)
   - [Android Setup](#android-setup)
   - [iOS Setup & App Groups](#ios-setup--app-groups)
6. [Security & App Hardening](#security--app-hardening)
7. [Getting Started & Installation](#getting-started--installation)
8. [Testing & Quality Assurance](#testing--quality-assurance)
9. [Assumptions & Trade-Offs](#assumptions--trade-offs)
10. [AI Pair Programming & Prompt Reference](#ai-pair-programming--prompt-reference)

---

## Core Features

- **Theme Management (Light & Dark Mode):**
  - Seamless, persistent theme switcher (Light, Dark, and System).
  - Exact Figma color tokens with high-contrast surfaces and accessible typography.
- **Authentication & Security Flow:**
  - PIN Management (Enter Current PIN, Create New PIN, Confirm PIN) with custom animated numpad.
  - Password Recovery with 6-digit OTP verification and real-time countdown timer.
  - Two-Factor Authentication (2FA) configuration and active status indicator.
- **Dashboard & Account Overview:**
  - Currency-formatted balance with privacy toggle (gated by biometrics or PIN).
  - Quick action buttons (Send, Receive/QR, Top-Up, Analytics).
  - Recent transactions list with status badges and beneficiary carousel.
  - Notification center with unread indicators.
- **KYC (Know Your Customer) Flows:**
  - Employment status dropdown and income band selection.
  - Bank statement upload state placeholders with progress feedback.
  - Identity verification (DOB picker, ID selector, front/back capture).
  - Selfie verification screen with custom face-alignment oval frame overlay.
- **QR Transfer & Payments:**
  - Integrated QR scanner with camera overlay and torch controls.
  - Personal receive QR code generator.
  - Realistic payment engine with simulated 1.5s network delay and explicit state machines.
- **Receipt Generation & Media I/O:**
  - High-resolution, pixel-perfect exportable transaction receipts.
  - Native file sharing (`share_plus`) and saving to device storage.
- **Native Home Screen Widget:**
  - Displays primary account balance and latest transaction details.
  - Automatic synchronization on balance/transaction mutations via `HomeWidget`.
  - Quick-launch deep link directly to the QR Scanner (`tappay://qr_scanner`).

---

## Architecture & Design Principles

The application is structured following **Clean Architecture** with strict layer boundaries:

```
lib/
├── app/                 # App configuration, routes (GoRouter), themes, and lifecycle observers
├── core/                # Shared utilities, networking, secure storage, errors, and base widgets
│   ├── errors/          # Custom exceptions, failure models, and error mappers
│   ├── network/         # HTTP/mock client, interceptors, connectivity watcher
│   ├── security/        # Biometrics, App Privacy Shield, crypto helpers
│   ├── storage/         # Secure storage facade and local preferences
│   ├── utils/           # Formatters (currency, dates) and responsive helpers
│   └── widgets/         # Reusable design system primitives
├── features/            # Feature-first domain modules
│   ├── auth/            # PIN lock, biometrics, OTP verification, 2FA
│   ├── dashboard/       # Balance card, quick actions, recent transactions
│   ├── kyc/             # Employment info, ID capture, face selfie verification
│   ├── qr_transfer/     # Camera scanner, QR generator, transfer controller
│   ├── transactions/    # Ledger, filtering, detail views, receipt generation
│   └── widgets_bridge/  # Native HomeWidget synchronization service
└── main.dart
```

### Key Principles:
- **Separation of Concerns:** Business logic is decoupled from Flutter widgets. UI views only observe state and dispatch intents.
- **Predictable State Transitions:** Sealed classes and Dart 3 pattern matching define exhaustive states (`Initial`, `Loading`, `Success`, `Failure`, `Empty`).
- **Responsive & Adaptive:** Layouts adapt seamlessly across breakpoints (Phone < 600dp, Tablet ≥ 600dp) with zero render overflow.

---

## Technology Stack & Package Choices

| Capability | Package / Technology | Rationale |
| :--- | :--- | :--- |
| **Framework** | Flutter 3.x+ / Dart 3.x | Sound null safety, pattern matching, records, and high performance. |
| **Navigation & Deep Linking** | `go_router` | Declarative routing, native deep link matching (`tappay://qr_scanner`). |
| **State Management** | BLoC / Cubit or Riverpod | Unidirectional data flow, high testability, and clear separation of presentation logic. |
| **Home Screen Widgets** | `home_widget` | Bridge for writing data to Android SharedPreferences and iOS App Groups (`UserDefaults`). |
| **Security & Biometrics** | `local_auth` & `flutter_secure_storage` | Hardware-backed biometric authentication with Keychain / KeyStore encrypted storage. |
| **QR Code I/O** | `mobile_scanner` & `qr_flutter` | High-performance native camera stream scanning and vector QR code rendering. |
| **Media & Receipt I/O** | `share_plus`, `path_provider` | Native file sharing and localized filesystem receipt export. |

---

## Native Platform Integration

### Android Setup
1. **App Privacy Shield (`MainActivity.kt`):**
   - Configured with `FLAG_SECURE` in window manager on resume/pause to obscure the app's contents in the Recent Apps switcher.
2. **Native Home Widget:**
   - `AppWidgetProvider` configured in `android/app/src/main/res/xml/`.
   - Layout defined with widget remote views displaying balance, merchant, and a launch intent for `tappay://qr_scanner`.
   - Receiver registered in `AndroidManifest.xml`.
3. **Permissions:**
   - `CAMERA` for QR scanning and selfie verification.
   - `USE_BIOMETRIC` for biometric authentication.

### iOS Setup & App Groups
1. **App Privacy Shield (`AppDelegate.swift`):**
   - A blur visual effect view or splash cover is placed over the key window when `applicationWillResignActive` is triggered and removed in `applicationDidBecomeActive`.
2. **Native WidgetKit Extension:**
   - Swift WidgetKit extension configured in Xcode with an **App Group** (e.g., `group.com.example.tappay`).
   - Widget reads shared `UserDefaults(suiteName: "group.com.example.tappay")` synced via `HomeWidget`.
   - Widget deep link URL handled via `onOpenURL` dispatching to `tappay://qr_scanner`.
3. **Permissions (`Info.plist`):**
   - `NSCameraUsageDescription` for QR code scanning and KYC identity capture.
   - `NSFaceIDUsageDescription` for biometric access.

---

## Security & App Hardening

1. **App Privacy Shield:** Prevents financial data leakage when switching between apps or capturing task thumbnails.
2. **Biometric & PIN Gating:** Viewing unmasked balances, transferring funds, or changing authentication credentials requires biometrics or fallback security PIN.
3. **Encrypted Storage:** Auth tokens, encryption keys, and PIN hashes are kept in hardware-backed secure storage (`flutter_secure_storage`).
4. **Idempotent Transfer Dispatch:** Double-tapping or rapid submission generates a unique idempotent client transaction token to prevent duplicated payments.

---

## Getting Started & Installation

### Prerequisites
- Flutter SDK 3.x+ installed (`flutter --version`)
- Xcode 15+ (for iOS testing)
- Android Studio / Android SDK (for Android testing)

### Installation
```bash
# Clone the repository
git clone https://github.com/your-username/tappay.git
cd tappay

# Install dependencies
flutter pub get

# Run analyzer to verify clean code
flutter analyze

# Run unit and widget tests
flutter test

# Run the app
flutter run
```

---

## Assumptions & Trade-Offs

1. **Network Simulation:** A realistic 1.5-second simulated latency is used for transactions and KYC uploads, allowing realistic testing of loading skeletons, optimistic UI, and error recovery without requiring a live banking backend.
2. **Biometrics in Simulators:** Local authentication falls back automatically to 4-digit PIN verification when running in emulators or devices without biometric hardware configured.
3. **Camera & File Pickers:** In simulator environments where physical cameras are unavailable, mocked image placeholders allow testing the complete KYC verification flow.

---

## AI Pair Programming & Prompt Reference

This repository is configured for autonomous and guided AI pair programming:
- **Master Specification:** [`PROJECT_SPECIFICATION.md`](file:///Users/macbook/Documents/Personal%20project/tappay/PROJECT_SPECIFICATION.md) contains the complete assessment requirements, rubric, and feature breakdown.
- **Workspace Agent Rules:** [`AGENTS.md`](file:///Users/macbook/Documents/Personal%20project/tappay/AGENTS.md) and [`GEMINI.md`](file:///Users/macbook/Documents/Personal%20project/tappay/GEMINI.md) are loaded into the assistant's context automatically on every prompt to enforce the architectural conventions, security standards, and UI matching.
