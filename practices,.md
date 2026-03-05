# Flutter Development Best Practices Framework (2026)

This document defines **rules, architecture, and tooling** for building the Flutter application.

The AI must follow these guidelines when generating or modifying code.

The goal is to produce a **modern, scalable, maintainable Flutter app using the latest ecosystem standards.**

---

# 1. Flutter & Dart Version

Use the **latest stable Flutter version**.

Requirements:

```
Flutter >= 3.29
Dart >= 3.3
```

Use modern Flutter features:

* Material 3 components
* Impeller rendering engine
* Stateful hot reload compatibility
* Null safety
* Dart records and pattern matching when useful

Flutter releases in 2025 introduced major improvements in performance and development workflows including improved rendering and hot reload behavior. ([dcm.dev][1])

---

# 2. Architecture

Follow **Clean Architecture + Feature-first modular structure**.

This ensures scalability and testability.

Clean architecture separates:

* UI
* Business logic
* Data layer

so the core logic does not depend on frameworks or UI implementations. ([happycoders.in][2])

## Architecture Layers

```
presentation/
domain/
data/
core/
```

### Presentation Layer

Responsibilities:

* UI widgets
* Screens
* UI state
* ViewModels / Controllers

### Domain Layer

Contains:

* Entities
* UseCases
* Repository interfaces

No dependency on Flutter or external packages.

### Data Layer

Contains:

* Repository implementations
* Local database
* API services
* DTO models

---

# 3. Project Folder Structure

Use **feature-based modularization**.

Example structure:

```
lib/
 ├ core/
 │  ├ constants/
 │  ├ theme/
 │  ├ utils/
 │  └ errors/
 │
 ├ features/
 │  ├ streak/
 │  │   ├ data/
 │  │   ├ domain/
 │  │   └ presentation/
 │  │
 │  ├ stats/
 │  │   ├ data/
 │  │   ├ domain/
 │  │   └ presentation/
 │
 ├ shared/
 │  ├ widgets/
 │  ├ components/
 │
 ├ services/
 │
 └ main.dart
```

Feature modularization improves scalability and maintainability for large Flutter apps. ([Brigita][3])

---

# 4. State Management

Preferred solution:

```
flutter_riverpod
```

Riverpod is currently considered the **recommended state management library for most Flutter projects** because it offers compile-time safety and minimal boilerplate. ([foresightmobile.com][4])

### State Guidelines

Use:

```
Riverpod Notifier
AsyncNotifier
StateNotifier
```

Rules:

* UI state → Riverpod providers
* Business logic → domain usecases
* No business logic in widgets
* Avoid global mutable state

---

# 5. Dependency Injection

Use:

```
riverpod
```

Avoid manual singleton services.

If needed:

```
get_it
injectable
```

Dependency injection ensures loose coupling and easier testing.

---

# 6. Navigation

Use modern routing:

```
go_router
```

Reasons:

* official Flutter recommendation
* declarative routing
* deep linking support

Example:

```
GoRouter(
  routes: [
    GoRoute(path: '/', builder: ...),
    GoRoute(path: '/stats', builder: ...)
  ]
)
```

---

# 7. Recommended Core Packages

Use only **well-maintained packages with high pub.dev adoption**.

## State Management

```
flutter_riverpod
riverpod_annotation
riverpod_generator
```

## Routing

```
go_router
```

## HTTP Networking

```
dio
```

## Local Database

Choose depending on complexity:

Simple apps:

```
hive
```

Structured apps:

```
isar
```

## Serialization

```
freezed
json_serializable
```

## Logging

```
logger
```

## Utility

```
equatable
intl
```

These packages are widely used in production Flutter apps and recommended across modern Flutter development guides. ([Medium][5])

---

# 8. UI Guidelines

Use:

```
Material 3
```

Rules:

* Dark theme first
* Use `ThemeData`
* Avoid inline styling
* Build reusable widgets

Example:

```
core/theme/app_theme.dart
```

Design principles:

* minimal UI
* consistent spacing
* reusable components

---

# 9. Performance Best Practices

Rules:

Avoid unnecessary rebuilds.

Use:

```
const widgets
ConsumerWidget
ref.watch selectively
```

Guidelines:

* avoid rebuilding entire screens
* scope state to minimal widgets
* use immutable state objects

Immutability improves debugging and performance in Flutter state management. ([vibe-studio.ai][6])

---

# 10. Code Style Rules

General guidelines:

* follow Dart style guide
* prefer small widgets
* avoid large build methods

Rules:

```
One widget per file
Functions < 50 lines
```

Avoid:

* business logic inside widgets
* large nested widget trees

Use `SizedBox` instead of `Container` for spacing when possible. ([Manektech][7])

---

# 11. Error Handling

Use structured error handling.

Example:

```
Result<T>
Either<Failure, Success>
```

Create error models inside:

```
core/errors
```

---

# 12. Testing

Write automated tests for core logic.

Types:

```
Unit tests
Widget tests
Integration tests
```

Test layers:

* UseCases
* Repositories
* ViewModels

---

# 13. Linting

Use strict lint rules.

Recommended:

```
flutter_lints
very_good_analysis
```

---

# 14. Build Tools

Use code generation where helpful.

Recommended tools:

```
build_runner
freezed
json_serializable
riverpod_generator
```

Command:

```
flutter pub run build_runner build --delete-conflicting-outputs
```

---

# 15. Security & Privacy

Rules:

* avoid storing sensitive data in plain text
* use secure storage if required

Example package:

```
flutter_secure_storage
```

---

# 16. Logging

Use structured logging.

Package:

```
logger
```

Rules:

* log errors
* disable verbose logs in production

---

# 17. Async & Networking

Use:

```
dio
```

Rules:

* centralized API client
* repository pattern
* error interceptors

---

# 18. Localization

Use:

```
flutter_localizations
intl
```

Structure:

```
l10n/
```

---

# 19. Git & Project Hygiene

Rules:

```
no large widgets
no unused dependencies
keep commits atomic
```

---

# 20. AI Code Generation Rules

When generating code:

1. Always follow **Clean Architecture**
2. Always use **Riverpod for state management**
3. Prefer **stateless widgets**
4. Keep UI and business logic separate
5. Write **scalable and testable code**
6. Avoid anti-patterns like global mutable state

---

# 21. Goal of the Codebase

The code should be:

```
Readable
Modular
Testable
Scalable
Maintainable
```

Every feature should be implemented as a **self-contained module**.

---

# END OF FRAMEWORK

[1]: https://dcm.dev/blog/2025/12/23/top-flutter-features-2025/?utm_source=chatgpt.com "Best Flutter Features in 2025"
[2]: https://www.happycoders.in/flutter-clean-architecture-a-practical-guide/?utm_source=chatgpt.com "Flutter Clean Architecture Guide for Scalable Apps (2025)"
[3]: https://brigita.co/best-practices-for-modularizing-large-flutter-apps-in-2025/?utm_source=chatgpt.com "Best Practices for Modularizing Large Flutter Apps in 2025"
[4]: https://foresightmobile.com/blog/best-flutter-state-management?utm_source=chatgpt.com "Best Flutter State Management Libraries 2026"
[5]: https://medium.com/%40flutter-app/top-10-flutter-packages-for-2025-must-have-libraries-every-developer-needs-a6b09d76b501?utm_source=chatgpt.com "Top 10 Flutter Packages for 2025 — Must-Have Libraries ..."
[6]: https://vibe-studio.ai/insights/state-management-in-flutter-best-practices-for-2025?utm_source=chatgpt.com "State Management in Flutter: Best Practices for 2025"
[7]: https://www.manektech.com/blog/flutter-development-best-practices?utm_source=chatgpt.com "Best Practices to implement for Flutter App Development in ..."
