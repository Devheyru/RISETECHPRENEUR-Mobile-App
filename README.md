# RiseTechpreneur Mobile App

**A cross-platform Flutter learning application for aspiring tech entrepreneurs in Ethiopia**

[![Flutter](https://img.shields.io/badge/Flutter-3.7.2+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.7.2+-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-Private-red)]()

---

## 📱 Overview

RiseTechpreneur is a modern mobile learning platform featuring course catalogs, blog content, user authentication, and a polished UI built with Riverpod state management and a custom design system.

**Live API**: `https://rise-techpreneur.havanacademy.com/api`

---

## ✨ Key Features

### 🔐 Authentication
- Complete auth flow (sign-in, sign-up, logout)
- Password reset via deep linking (`risetechpreneur://reset-password`)
- Secure JWT token storage with `flutter_secure_storage`
- Session persistence across app restarts
- Professional error handling with user-friendly messages

### 📚 Learning Platform
- Course catalog with category filtering
- Blog posts for entrepreneurs
- Auto-scrolling testimonials
- Auth-gated enrollment system
- Responsive grid layouts

### 🎨 Design System
- **Primary**: #155DFC (Blue)
- **Secondary**: #1E293B (Navy)
- **Typography**: Inter font family
- Material Design 3 components
- Floating snackbars with color coding

### 🧭 Navigation
- Custom bottom navigation (5 tabs)
- State preservation with `IndexedStack`
- Deep link support for password reset

---

## 🏗️ Architecture

```
lib/
├── core/                    # Theme, colors, utilities
│   ├── app_theme.dart       # Design system
│   ├── constants.dart       # App constants
│   └── error_handler.dart   # Error handling utilities
│
├── data/                    # Models & state providers
│   ├── models.dart          # Domain models
│   ├── providers.dart       # Mock data providers
│   └── auth_provider.dart   # Auth state management
│
├── presentation/
│   ├── screens/             # Feature screens
│   │   ├── main_navigation.dart
│   │   ├── home_screen.dart
│   │   ├── courses_screen.dart
│   │   ├── blog_screen.dart
│   │   ├── contact_screen.dart
│   │   ├── more_screen.dart
│   │   ├── settings_screen.dart
│   │   ├── auth_screen.dart
│   │   └── reset_password_screen.dart
│   │
│   └── widgets/             # Reusable components
│       ├── components.dart
│       ├── blog_posts.dart
│       └── [other widgets]
│
└── main.dart                # App entry point
```

---

## 🛠️ Tech Stack

| Component | Technology | Version |
|-----------|-----------|---------|
| Framework | Flutter | 3.7.2+ |
| State Management | Riverpod | 3.0.3 |
| Typography | Google Fonts (Inter) | 6.3.2 |
| HTTP Client | http | 1.6.0 |
| Secure Storage | flutter_secure_storage | 9.2.4 |
| Deep Linking | app_links | 6.4.1 |
| URL Launcher | url_launcher | 6.3.2 |
| Dev Preview | device_preview | 1.3.1 |

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK ≥3.7.2
- Dart SDK ≥3.7.2
- Android Studio / Xcode (for mobile)
- VS Code or Android Studio with Flutter plugins

### Installation

```bash
# Clone the repository
git clone <repository-url>
cd RISETECHPRENEUR-Mobile-App/risetechpreneur

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Platform Setup

**Android**: Firebase configured (Project ID: `rise-tech-121`)  
**iOS**: Firebase configured  
**Web & Desktop**: Basic support enabled

---

## 🔐 Authentication API

### Endpoints
- `POST /login-user` – Sign in
- `POST /create-user` – Registration
- `POST /logout-user` – Sign out
- `POST /password/reset/request` – Request reset email
- `POST /password/reset` – Reset with token
- `POST /password/update` – Update password

### Validation
- **Email**: Standard format
- **Phone**: Ethiopian format (+251XXXXXXXXX)
- **Password**: Minimum 6 characters

### Deep Link Format
```
risetechpreneur://reset-password?token=<TOKEN>&email=<EMAIL>
```

---

## 📊 Current Status

### ✅ Implemented
- Complete authentication system
- User session management
- Password reset flow
- Home screen with hero section
- Course catalog with filtering
- Blog section
- Contact form
- Settings & profile display
- Professional error handling
- Performance optimizations

### ⚠️ Mock Data (Needs API Integration)
- Courses (7 samples)
- Categories (12 items)
- Testimonials (3 items)
- Blog posts (3 items)

### 🚧 Placeholders
- Course detail screen
- Events page
- Terms of Service
- Privacy Policy
- App settings preferences

---

## 🎯 Roadmap

### High Priority
1. Connect mock data to real API endpoints
2. Implement course detail screen
3. Add search functionality
4. Complete placeholder screens
5. Implement unit & widget tests

### Medium Priority
6. User profile editing
7. Course enrollment flow
8. Push notifications
9. Token refresh mechanism
10. Biometric authentication

### Low Priority
11. Offline support with caching
12. Analytics integration
13. Multi-language support
14. Social login (Google, Apple)

---

## 🧪 Testing

**Current Status**: Test directory exists but no tests implemented

**Recommended**:
- Unit tests for `AuthState` methods
- Widget tests for authentication flow
- Integration tests for navigation
- API mock tests for data providers

---

## 📝 Documentation

All technical documentation has been consolidated into this README. Previous analysis documents covered:
- ✅ Complete authentication system analysis
- ✅ Error handling improvements
- ✅ Performance optimizations

---

## 🤝 Contributing

This project follows Flutter best practices:
- **State Management**: Riverpod for reactive state
- **Architecture**: Feature-based organization
- **Theming**: Centralized design system
- **Code Style**: Dart style guide with enforced linting

---

## 📄 License

*Private project - All rights reserved*

---

## 👥 Contact

**RiseTechpreneur** – Empowering Ethiopian Tech Entrepreneurs

- **Website**: https://rise-techpreneur.havanacademy.com
- **Email**: info@risetechpreneur.com

---

**Last Updated**: December 12, 2025  
**Version**: 1.0.0+1  
**Status**: Active Development
