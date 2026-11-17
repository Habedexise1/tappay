# TapPay — Fintech Mobile Client (Flutter)

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)

TapPay is a responsive fintech mobile client built in Flutter from the [TapPay Figma Community design](https://www.figma.com/design/bk4bA3ldr2bdRuk7xr6c1O5/TapPay--Community-?node-id=0-1&t=f8mMtG9MBlng915l-1). It covers the full onboarding, authentication, dashboard, KYC, QR transfer and receipt flows, a native Home Screen widget on Android and iOS, and fintech hardening (privacy shield, biometric/PIN gating, secure storage, idempotent transfers).

---

## Table of Contents
1. [Core Features](#core-features)
2. [Architecture](#architecture)
3. [Package Choices](#package-choices)
4. [Native Platform Integration](#native-platform-integration)
5. [Security & Resilience](#security--resilience)
6. [Getting Started](#getting-started)
7. [Testing](#testing)
8. [Demo Checklist](#demo-checklist)
9. [Assumptions & Trade-Offs](#assumptions--trade-offs)

---

## Core Features

- **Theme management** — Light and dark modes using Figma colour tokens (`lib/app/theme`). The app follows the system setting until the user picks a mode, and the choice is persisted with `shared_preferences`.
- **Authentication & security** — Create, confirm, enter and change PIN screens with a custom numpad; password reset OTP with a countdown timer; 2FA type selection with an active status indicator; biometric enrolment.
- **Dashboard** — Currency-formatted balance with a biometric-gated reveal toggle, multi-currency picker, quick actions, beneficiaries, notifications and recent transactions with skeleton loaders.
- **KYC** — Employment ("What do you do?"), income bands, bank statement / utility uploads, date of birth, ID type, ID photo capture and selfie verification with a face-alignment overlay. Separate USD and GBP/EUR flows.
- **Transfers** — TapTag, bank and QR transfers share one controller with a simulated 1.5s network call and explicit `Loading → Success / Failure` states, reusable success and failure result screens, and retry.
- **QR** — `mobile_scanner` camera scanner with torch control and a personal receive QR generator.
- **Receipts** — Receipts are rendered from a `RepaintBoundary` to a 3× PNG, shared with `share_plus`, or saved anywhere on the device through the system save dialog.
- **Home Screen widget** — Shows the primary balance and the last transaction (amount and merchant); tapping it opens the QR scanner via `tappay://qr_scanner`.
- **Adaptive layout** — Phones use a bottom navigation bar; at ≥ 600dp the dashboard switches to a side navigation rail (extended at ≥ 1024dp), and once the content area is ≥ 840dp wide (e.g. a tablet in landscape) the home view splits into summary and activity columns.

---

## Architecture

Feature-first Clean Architecture with Provider `ChangeNotifier` controllers:

```
lib/
├── app/
│   ├── config/              # Asset paths
│   ├── observers/           # AppLifecycleObserver (drives the privacy shield)
│   ├── routes/              # AppRoutes named-route table (deep links, scanner, ledger)
│   └── theme/               # Colour tokens, typography, ThemeController
├── core/
│   ├── errors/              # AppException hierarchy, sealed Failure types, ErrorMapper
│   ├── network/             # NetworkSimulator (latency + failure injection)
│   ├── security/            # BiometricsService, AppPrivacyShield
│   ├── storage/             # SecureStorageService, PreferencesService
│   ├── utils/               # Currency/date formatters, breakpoints, sealed ViewState
│   └── widgets/             # Design-system primitives, nav bar + side rail, skeletons, result screens
├── features/
│   ├── auth/                # domain / data / presentation: PIN, OTP, password, 2FA, sign-up
│   ├── dashboard/           # domain / data / presentation: home, P2P, send money, cards
│   ├── kyc/                 # domain / data / presentation for KYC flows
│   ├── onboarding/          # Splash and welcome carousel
│   ├── qr_transfer/         # QR payload, scanner, generator, QrTransferController
│   ├── settings/            # Profile, security, notifications, referrals
│   ├── transactions/        # Repository, ledger, receipt screen, ReceiptExporter
│   └── widgets_bridge/      # HomeWidgetService (sync) + WidgetLaunchService (deep links)
└── main.dart                # Dependency wiring (MultiProvider) and widget deep-link routing
```

- **Layering** — Widgets render state and dispatch intents. Controllers (`AuthController`, `DashboardController`, `QrTransferController`, `KycController`, …) hold validation and state transitions only. All storage and network work sits behind repository interfaces in each feature's `domain/` folder (`AuthRepository`, `DashboardRepository`, `TransactionRepository`, `KycRepository`, `SettingsRepository`), implemented by mocks in `data/`. Repository exceptions are mapped to typed failures by `ErrorMapper`.
- **State** — `ViewState<T>` is a Dart 3 `sealed class` (`Initial`, `Loading`, `Success`, `Failure`, `Empty`) consumed with exhaustive `switch` pattern matching. Export results (`ReceiptExportResult`) and failures (`Failure`) are also sealed.
- **Injection** — Platform dependencies (biometrics, secure storage, widget sync, camera, media source, transaction repository and its network latency) are injected through `TapPayRoot`, and repositories through controller constructors, so tests swap in fakes.

---

## Package Choices

| Capability | Package | Why |
| :--- | :--- | :--- |
| State management | `provider` | Lightweight `ChangeNotifier` controllers with proxy providers for cross-feature dependencies. |
| Home Screen widget | `home_widget` | Writes to Android `SharedPreferences` / iOS App Group `UserDefaults` and triggers widget reloads. |
| Biometrics | `local_auth` | Face ID / fingerprint, falling back to the device passcode. |
| Secure storage | `flutter_secure_storage` | PIN, password, token and security flags in Keychain / EncryptedSharedPreferences. |
| Preferences | `shared_preferences` | Theme, balance mask and the mock balance. |
| QR | `mobile_scanner`, `qr_flutter` | Native camera scanning and vector QR rendering. |
| Receipts | `share_plus`, `file_picker`, `path_provider` | Share sheet, user-chosen save location, temp files. |
| KYC media | `camera`, `image_picker`, `file_picker`, `permission_handler` | Selfie capture, ID photos, document uploads, permission lifecycle. |
| UI | `flutter_svg`, `pinput`, `intl` | Figma SVG icons, OTP input fields, currency and date formatting. |
| Motion | `flutter_animate`, `lottie` | Micro-interactions and success animations. |

---

## Native Platform Integration

### Android

| File | Purpose |
| :--- | :--- |
| `android/app/src/main/kotlin/com/example/tappay/MainActivity.kt` | `FlutterFragmentActivity` (required by `local_auth`). Hides the Recents thumbnail with `setRecentsScreenshotEnabled(false)` on API 33+, and sets `FLAG_SECURE` while paused on older versions, so screen recording still works in the foreground. |
| `.../TapPayWidgetProvider.kt` | `HomeWidgetProvider` that binds the stored balance and last transaction to `RemoteViews` and attaches a `HomeWidgetLaunchIntent` for `tappay://qr_scanner?homeWidget`. |
| `res/layout/tappay_widget.xml`, `res/xml/tappay_widget_info.xml` | Widget layout (4×2, resizable) and provider metadata. |
| `res/values{,-night}/widget_colors.xml` | Light and dark widget palettes matching the app tokens. |
| `AndroidManifest.xml` | Widget `<receiver>`, `CAMERA` / `USE_BIOMETRIC` permissions, and the `tappay://qr_scanner` intent filter. |

**Adding the widget:** long-press the home screen → Widgets → TapPay.

### iOS

| File | Purpose |
| :--- | :--- |
| `ios/TapPayWidget/TapPayWidget.swift` | WidgetKit extension (`systemSmall`, `systemMedium`) reading `UserDefaults(suiteName: "group.com.example.tappay")`, with `widgetURL(tappay://qr_scanner?homeWidget)`. |
| `ios/Runner/TapPaySceneBridge.swift` | Plugin registered as a `FlutterSceneLifeCycleDelegate`. It forwards widget URLs to Dart on the `tappay/widget_link` channel, and adds a blur cover in `sceneWillResignActive` that is removed in `sceneDidBecomeActive` (App Switcher privacy). |
| `ios/Runner/Runner.entitlements`, `ios/TapPayWidget/TapPayWidget.entitlements` | Shared App Group `group.com.example.tappay`. |
| `ios/Runner/Info.plist` | `tappay` URL scheme, plus camera, photo library and Face ID usage descriptions. |

The `TapPayWidgetExtension` target is already in `Runner.xcodeproj` and embedded in the app's "Embed Foundation Extensions" phase (placed before "Thin Binary" to avoid the Flutter build cycle).

**Signing for a device:**
1. In Xcode, select your team for both the **Runner** and **TapPayWidgetExtension** targets.
2. If you change the bundle ID or can't use `group.com.example.tappay`, create your own App Group and update it in both `.entitlements` files, `HomeWidgetService.appGroupId` and `WidgetStore.appGroupId` in `TapPayWidget.swift`.
3. The simulator needs no signing: `flutter build ios --simulator`.

### Data flow

```
QrTransferController / DashboardController
        │ balance or transaction changes
        ▼
HomeWidgetService.syncBalance / syncLastTransaction
        │ HomeWidget.saveWidgetData + updateWidget
        ▼
SharedPreferences (Android) / App Group UserDefaults (iOS)
        ▼
TapPayWidgetProvider / TapPayWidget timeline reload

Widget tap → tappay://qr_scanner?homeWidget
        ▼
Android: HomeWidget.widgetClicked   iOS: TapPaySceneBridge → tappay/widget_link
        ▼
WidgetLaunchService.links → QrScannerScreen
```

The widget mirrors the in-app currency selection and balance mask, so a hidden balance stays hidden on the home screen.

---

## Security & Resilience

1. **Privacy shield** — Native protection on both platforms (above), plus a Flutter blur overlay: `AppLifecycleObserver` (`app/observers`) flags `inactive` / `paused` / `hidden` states and `AppPrivacyShield` renders the cover.
2. **Biometric / PIN gating** — Revealing a hidden balance and authorising QR transfers require `local_auth` (Face ID / fingerprint, falling back to the device passcode). TapTag and bank transfers require the 4-digit app PIN in `ConfirmPinSheet`, which also offers a biometric shortcut. Changing the PIN or password requires the current one.
3. **Secure storage** — The PIN, password, session token and security flags live in `flutter_secure_storage` (EncryptedSharedPreferences on Android, Keychain on iOS). `shared_preferences` holds only the theme, the balance-mask flag and the mock balance.
4. **Idempotent transfers** — `QrTransferController` derives one idempotency key per transfer intent (recipient + amount + category) and reuses it on retry until the transfer succeeds. `MockTransactionRepository` returns the settled transaction for a repeated key and coalesces concurrent requests with the same key, so double taps and retries after a timeout never double-charge. Submits while a transfer is in flight are ignored.
5. **Error mapping** — Exceptions (`NetworkException`, `InsufficientFundsException`, …) are mapped to sealed `Failure` types by `ErrorMapper` and shown on the failure result screen with a retry action.

---

## Getting Started

**Prerequisites:** Flutter stable with Dart 3.12+ (built and tested with Flutter 3.44.2), Xcode with an iOS 15.5+ SDK, and the Android SDK via Android Studio.

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

Debug APK: `flutter build apk --debug` → `build/app/outputs/flutter-apk/app-debug.apk`.

---

## Testing

| Suite | Covers |
| :--- | :--- |
| `test/architecture_layers_test.dart` | Auth and dashboard repositories, controller ↔ repository failure mapping, the lifecycle observer and the route table. |
| `test/transfer_resilience_test.dart` | Repository idempotency (replay, concurrent coalescing, retry after failure), `QrTransferController` state machine (success, biometric rejection, insufficient funds, retry with the same key, double-submit guard), widget sync after a balance change, `ErrorMapper`, deep-link parsing. |
| `test/security_dashboard_flow_test.dart` | PIN creation, light/dark dashboard, currency switching, the end-to-end send-money flow to the success screen, and the phone/tablet breakpoint switch. |
| `test/auth_flow_test.dart` | Auth screens and PIN flows. |
| `test/kyc_flow_test.dart` | USD and GBP/EUR KYC flows, camera permission states, selfie capture. |
| `test/settings_feature_test.dart` | Settings actions, theme persistence, 2FA, password and PIN changes. |
| `test/widget_test.dart` | Splash and welcome screen rendering, including the theme toggle. |

Flow tests use `NetworkSimulator.instant()` so they run without real network delays.

---

## Demo Checklist

1. **Responsive layout** — Rotate a phone to landscape: the bottom bar becomes a side rail. On a tablet the rail shows in portrait, and rotating to landscape extends it and splits the home view into two columns.
2. **Widget sync** — Add the TapPay widget, open the app, send money from the dashboard, then return to the home screen: the balance and last transaction update. Tap the widget to open the QR scanner.

---

## Assumptions & Trade-Offs

1. **Mock backend** — There is no live banking API. Repositories are in-memory mocks behind interfaces, with `NetworkSimulator` adding 1.5s latency to transfers (0.8s to the ledger) and optional failure injection.
2. **Idempotency scope** — Settled keys are kept in memory for the app session; a production backend would persist them server-side with a TTL.
3. **Provider over BLoC/Riverpod** — Chosen for low ceremony. Controllers stay framework-light and unit-testable, and state is still modelled with sealed classes.
4. **Navigation** — Flows use imperative `Navigator` routes because many are bottom-sheet driven; `AppRoutes` provides named routes for entry points such as the widget deep link to the QR scanner.
5. **Privacy vs. recording** — On Android 13+ only the Recents thumbnail is hidden (`setRecentsScreenshotEnabled`), so demo screen recordings still work. On older versions `FLAG_SECURE` is applied only while the app is paused.
6. **Biometrics on emulators** — Biometric prompts fall back to the device passcode; if no biometrics or passcode are set up, the prompt fails and the action is refused. TapTag and bank transfers can always be authorised with the app PIN.
7. **Camera on simulators** — ID photos and documents can be picked from the gallery or files, but selfie capture needs a real camera; without one the selfie step shows a "No camera found" error.
