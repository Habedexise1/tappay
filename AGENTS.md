# TapPay AI Pair Programmer Instructions & Rules

> **CRITICAL DIRECTIVE**:
> For **every prompt, task, or feature request** received in this repository, you **MUST** refer back to [`PROJECT_SPECIFICATION.md`](file:///Users/macbook/Documents/Personal%20project/tappay/PROJECT_SPECIFICATION.md) and adhere to the architectural guidelines, feature requirements, security standards, and evaluation criteria defined below.

---

## 1. Project Context & Mission
You are building **TapPay**, a high-performance, responsive, production-ready fintech mobile client in Flutter. The implementation is evaluated on:
1. **Architecture & State Management (25%)** — Clean Architecture (Presentation, Domain, Data), decoupled business logic, immutable sealed state classes with Dart 3 pattern matching.
2. **Native Integration (20%)** — Home Screen Widget (`HomeWidget` IPC sync for balance & recent transaction), QR code scanner deep links (`tappay://qr_scanner`), permissions, and native platform configuration (`MainActivity.kt`, Swift WidgetKit extension).
3. **Responsiveness & UX Polish (20%)** — Adaptive phone and tablet layouts, smooth 60fps micro-animations, skeleton loaders, and zero UI overflow (`RenderFlex` errors).
4. **Fintech Security & Resilience (15%)** — Native App Privacy Shield (obscuring screen in recent apps / task switcher), Biometric authentication (`local_auth`) with 4-digit PIN fallback, secure token storage (`flutter_secure_storage`), and idempotent operations.
5. **Receipt Generation & Media I/O (10%)** — High-fidelity exportable receipt images/documents, file sharing (`share_plus`), and local saving.
6. **Testing & Documentation (10%)** — Robust unit and widget tests, clean setup documentation, and conventional commits.

- **Figma Design Reference:**
  [TapPay Figma Community File](https://www.figma.com/design/bk4bA3ldr2bdRuk7xr6c1O5/TapPay--Community-?node-id=0-1&t=f8mMtG9MBlng915l-1)

---

## 2. Directory & Architecture Standards

Always organize code inside `lib/` following this clean structure:

```
lib/
├── app/
│   ├── config/              # App constants, environment settings
│   ├── routes/              # Declarative router (GoRouter), route paths, deep-link handling
│   ├── theme/               # Light & Dark color tokens matching Figma, typography, theme controller
│   └── observers/           # App lifecycle & router observers
├── core/
│   ├── errors/              # Custom exceptions, failure models, error mappers
│   ├── network/             # Network client, interceptors, mock delay handlers
│   ├── security/            # Biometrics helper, privacy shield observer, crypto utils
│   ├── storage/             # Secure storage facade, shared preferences wrapper
│   ├── utils/               # Formatters (currency, dates), responsive breakpoints
│   └── widgets/             # Reusable UI primitives (buttons, inputs, cards, dialogs)
├── features/
│   ├── auth/                # PIN management, OTP recovery, 2FA setup
│   ├── dashboard/           # Home balance view, quick actions, beneficiaries, alerts
│   ├── kyc/                 # Employment info, ID capture, face selfie verification
│   ├── qr_transfer/         # QR camera scanner, generator, payment controller
│   ├── transactions/        # Transaction ledger, filter, detail, receipt generator
│   └── widgets_bridge/      # HomeWidget native sync service
└── main.dart
```

---

## 3. Mandatory Engineering Rules

1. **Clean Layer Separation:**
   - Widgets must **only** handle UI rendering and user event dispatching.
   - All state transitions, business rules, and API mocks must live in controllers/blocs/cubits and domain use cases.
   - Utilize Dart 3 `sealed class` hierarchies for UI states (`Initial`, `Loading`, `Success`, `Failure`, `Empty`).

2. **Theming & UI Matching:**
   - Both **Light** and **Dark** modes must be fully supported with a persistent switch.
   - Use custom color palettes matching the Figma design tokens. Maintain high contrast on dark surfaces.
   - Support adaptive breakpoints for mobile screens and tablets (>= 600dp).

3. **Security Standards:**
   - Always implement the App Privacy Shield lifecycle observer (blurring/obscuring screen in background/app switcher).
   - Sensitive operations (revealing balance, confirming transactions, changing PIN) must be gated by biometrics or 4-digit PIN.
   - Sensitive credentials/keys must use `flutter_secure_storage`.

4. **Home Screen Widget Sync:**
   - Any transaction mutation or balance update must invoke the `HomeWidget` bridge to synchronize the native widget.
   - Support the deep link scheme `tappay://qr_scanner` from the widget tap.

5. **Code Style & Commits:**
   - Dart 3 sound null safety, pattern matching, records where suitable.
   - Run `flutter analyze` and maintain zero warnings.
   - Use conventional commit format: `feat:`, `fix:`, `refactor:`, `test:`, `docs:`, `chore:`.

---

## 4. How to Execute Incoming Prompts

When given any prompt:
1. Identify which feature/requirement from `PROJECT_SPECIFICATION.md` is being addressed.
2. Confirm the appropriate architecture layer and file destination before writing code.
3. Validate responsiveness, dark/light theme support, and error states.
4. Keep the documentation updated as milestones are achieved.
