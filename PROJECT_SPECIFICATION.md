# TapPay — Technical Specification & Assessment Reference

This document serves as the master specification, execution blueprint, and reference manual for building **TapPay**, a responsive, production-ready fintech mobile client in Flutter. All engineering prompts, architectural decisions, and code implementations in this repository must align with the instructions and standards set forth here.

---

## 1. Project Overview & Objectives

- **App Name:** TapPay
- **Form Factors:** Mobile Phone & Tablet (Adaptive/Responsive design across breakpoints)
- **Primary Objective:** Deliver an enterprise-grade, secure, performant, and polished fintech application adhering to clean architecture, modern Dart 3 features, and native mobile capabilities.
- **Figma Design Reference:**
  [TapPay Figma Community File](https://www.figma.com/design/bk4bA3ldr2bdRuk7xr6c1O5/TapPay--Community-?node-id=0-1&t=f8mMtG9MBlng915l-1)
- **Target Platform:** iOS & Android (with Flutter stable channel 3.x+ and Dart 3.x+ with sound null safety and pattern matching)

---

## 2. Evaluation Rubric & Quality Gates

| Criteria | Weight | Target Standards & What We Look For |
| :--- | :--- | :--- |
| **Architecture & State Management** | **25%** | Strict clean layer boundaries (Domain, Data, Presentation), testable controllers/blocs/notifiers, no business logic leaks into UI widgets, predictable state transitions with sealed classes and pattern matching. |
| **Native Integration (Home Widget & QR)** | **20%** | Configured native files (`MainActivity.kt`, `AppWidgetProvider`, Swift WidgetKit extension / App Groups), functional IPC synchronization (`HomeWidget`), smooth camera lifecycle, and graceful permission handling. |
| **Responsiveness & UX Polish** | **20%** | Adaptive layout across screen breakpoints (phone portrait/landscape, tablet), 60fps micro-interactions/animations, skeleton loading placeholders, informative error feedback, zero UI overflow (`RenderFlex` errors). |
| **Fintech Security & Resilience** | **15%** | Privacy shield/blur in recent apps switcher, biometric auth / PIN lock protecting sensitive actions, secure credential storage (`flutter_secure_storage`), idempotent transaction dispatch. |
| **Receipt Generation & Media I/O** | **10%** | Pixel-perfect exportable receipt document/image without UI artifacts or resolution degradation, system sharing (`share_plus`), and saving to local storage. |
| **Testing & Documentation** | **10%** | Comprehensive unit tests (state machines, repositories, use cases), widget tests for core components, and clear setup/native configuration documentation. |

---

## 3. Core Feature Requirements

### 3.1 Theme Management (Light & Dark Mode)
- **Dynamic Persistent Switcher:** Support user-triggered theme switching (System, Light, Dark) persisted across app launches via local storage.
- **Figma Color Tokens:** Accurate color palettes matching the Figma design for both Light and Dark themes.
- **Contrast & Typography:** Strict adherence to high-contrast surface/background pairings and accessible readability.

### 3.2 Authentication & Security Flow
- **PIN Management:**
  - Enter Current PIN, Create New PIN, and Confirm PIN screens.
  - Custom numpad widget and animated digit indicator/boxes.
  - Haptic feedback and maximum retry / lockout policies.
- **Password Recovery:**
  - Phone / Email OTP verification screen with real-time countdown timer (resend OTP cooldown).
  - Input auto-focus and auto-submit upon 6-digit completion.
- **Two-Factor Authentication (2FA):**
  - Configuration screen to select 2FA method (SMS, Authenticator App, Email).
  - Visual status indicator showing active 2FA state.

### 3.3 Dashboard & Account Overview
- **Main Dashboard Scaffolding:**
  - Formatted currency balance display matching Figma specs.
  - Balance visibility toggle (eye icon) with biometric or PIN verification gate.
  - Quick action buttons (Send, Receive/QR, Top-Up, Analytics).
  - Recent transactions list with transaction status badges, merchant tags, and dates.
  - Beneficiaries carousel / avatar list with rapid selection.
  - Notification center header and unread indicator badge.

### 3.4 KYC (Know Your Customer) Flows
- **Employment & Income Information:**
  - Employment status picker ("What do you do?": Unemployed, Employed, Self-employed, Student, etc.).
  - Income band selection ranges (e.g., $0–$1,000, $1,000–$5,000, etc.).
  - Bank statement file upload placeholder states (supporting file pickers and upload progress simulations).
- **Identity Verification (ID & Selfie):**
  - Date of birth pickers with validation.
  - ID type selector (National ID, Passport, Driver's License).
  - Front-view and back-view ID card photo upload / capture preview.
  - **Selfie Verification Screen:** Custom face-alignment frame overlay (oval guideline) with real-time feedback and functional "Take a selfie" trigger state.

### 3.5 QR Transfer & Payment Engine
- **QR Code Scanner:**
  - Camera scanner with torch toggle, scanner overlay, and permission lifecycle handling.
  - Quick parse of payload: recipient account/tag, preset amount, and reference notes.
- **QR Code Generator:**
  - Generate dynamic personal receive QR codes with custom requested amounts.
- **Transfer Controller & Simulation:**
  - Simulated network latency (1.5-second delay) for realistic feedback.
  - Explicit pending state transitions ($\text{Pending} \to \text{Success} \mid \text{Failure}$).
  - Idempotent transfer execution preventing accidental double submits.

### 3.6 Success & Error States & Receipt Generation
- **Reusable Result Screens:**
  - Dedicated Success and Failed transaction screens featuring animated vector icons, breakdown summaries, and fallback CTAs ("Done", "Try Again", "View Receipt").
- **Receipt Generation & Media I/O:**
  - High-resolution receipt rendering (using RepaintBoundary or PDF generator).
  - Zero artifacting or clipping across different screen densities.
  - System file sharing via `share_plus` and file saving to device gallery/storage.

### 3.7 Native Home Screen Widget Integration
- **Sync Engine (`HomeWidget`):**
  - Whenever a transaction completes or the balance mutates, flush updated data to native storage (`HomeWidget.saveWidgetData` and `HomeWidget.updateWidget`).
- **Widget Content:**
  - Primary account balance (synced with app state).
  - Last transaction amount and merchant/tag.
  - Deep Link action: Tapping the widget opens the app directly into the QR Scanner flow (`tappay://qr_scanner`).
- **Platform Files:**
  - Android: `AppWidgetProvider`, XML layout, and widget receiver in `AndroidManifest.xml`.
  - iOS: Swift WidgetKit extension and shared App Group identifier.

### 3.8 Security & App Hardening
- **App Privacy Shield:**
  - Native obscuring: Automatically display a blank, blurred, or branded splash view in the native task switcher (Recent Apps on Android, App Switcher on iOS) to prevent financial data leakage.
- **Biometric Authentication (`local_auth`):**
  - Guard balance display toggle and outgoing transfers with Face ID, Touch ID, or fingerprint.
  - Seamless fallback to 4-digit security PIN if biometric hardware is unavailable or disabled.
- **Secure Storage (`flutter_secure_storage`):**
  - Tokens, encryption keys, and PIN hashes must reside in the iOS Keychain and Android EncryptedSharedPreferences / KeyStore.

---

## 4. Architectural Standards & Project Structure

The project strictly follows Clean Architecture:

```
lib/
├── app/
│   ├── config/              # App config, constants, environment settings
│   ├── routes/              # Declarative routing (GoRouter / auto_route) & deep-link handlers
│   ├── theme/               # Light/Dark ColorSchemes, Typography, ThemeCubit/Provider
│   └── observers/           # Navigation and state observers
├── core/
│   ├── errors/              # Failures, exceptions, error mapper
│   ├── network/             # Network client, interceptors, connectivity watcher
│   ├── security/            # Biometrics helper, privacy shield observer, crypto utils
│   ├── storage/             # Secure storage facade, shared preferences wrapper
│   ├── utils/               # Currency formatters, date formatters, responsive helpers
│   └── widgets/             # Reusable UI primitives (buttons, inputs, dialogs, cards)
├── features/
│   ├── auth/                # PIN management, OTP recovery, 2FA setup
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── dashboard/           # Balance view, quick actions, beneficiaries, alerts
│   ├── kyc/                 # Employment info, ID capture, face selfie verification
│   ├── qr_transfer/         # QR camera scanner, generator, payment controller
│   ├── transactions/        # Transaction ledger, filter, detail, receipt generator
│   └── widgets_bridge/      # HomeWidget IPC synchronizer and deep-link dispatcher
└── main.dart
```

### Layer Constraints:
1. **Domain Layer:** Pure Dart. Contains Entities, Value Objects, and Repository interfaces. Zero UI or third-party dependencies.
2. **Data Layer:** Implements Repository interfaces, manages Data Sources (remote API mock, local database, secure storage), and maps Models to Entities.
3. **Presentation Layer:** State management controllers (Bloc/Cubit, Riverpod, or Provider), View Models, and UI widgets. Business logic must never reside in widgets.
4. **State Modeling:** Utilize Dart 3 `sealed class` hierarchy for UI states:
   ```dart
   sealed class ViewState<T> {
     const ViewState();
   }
   class Initial<T> extends ViewState<T> { const Initial(); }
   class Loading<T> extends ViewState<T> { const Loading(); }
   class Success<T> extends ViewState<T> { final T data; const Success(this.data); }
   class Failure<T> extends ViewState<T> { final String message; const Failure(this.message); }
   ```

---

## 5. Coding & Workflow Guidelines for AI Pair Programming

Whenever performing any task in this codebase, the agent must:
1. **Reference This Spec:** Verify every new feature or refactor against this document and Figma design requirements.
2. **Commit Hygiene:** Maintain structured conventional commit messages (`feat:`, `fix:`, `refactor:`, `test:`, `docs:`, `chore:`).
3. **Responsive Verification:** Ensure all screens adapt smoothly between Phone (< 600dp) and Tablet (>= 600dp) without overflow.
4. **Security First:** Never expose unencrypted secrets or sensitive credentials. Ensure Privacy Shield and Biometrics are intact.
5. **Quality Verification:** Keep tests passing, ensure zero lint warnings with `flutter_lints`, and verify null safety.
