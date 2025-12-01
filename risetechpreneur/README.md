## RiseTechpreneur – Mobile App

RiseTechpreneur is a Flutter-powered learning platform for aspiring tech entrepreneurs.  
It showcases a modern course catalog, curated blog content, testimonials, and a polished
mobile UI built with Riverpod and custom design components.

---

## Features

- **Onboarding & Auth**
  - Tabbed sign-in / sign-up screen (`AuthScreen`)
  - Mocked email/password flows powered by `AuthState` and `authProvider`

- **Home Experience**
  - Hero section with CTA and key stats (`HomeScreen`)
  - Popular courses, categories, testimonials, and blog sections
  - Auto-scrolling testimonial carousel

- **Courses**
  - Dedicated Courses screen with:
    - Horizontally scrollable category chips
    - "All" category support
    - Live filtering of the course grid

- **Blog**
  - Blog list screen backed by `blogsProvider`
  - Reusable `BlogCard` widget for both home and blog screens

- **Contact & Settings**
  - Contact screen with quick actions (email, phone, address) and a contact form
  - Settings screen showing profile summary plus placeholder account/preferences options

- **Navigation & Theming**
  - Custom bottom navigation bar (`MainNavigation`) using an `IndexedStack`
  - Centralized theme & color system in `core/app_theme.dart`

---

## Project Structure

```text
lib/
  core/            # Theme, colors, shared constants & utilities
  data/            # Domain models and Riverpod providers (mock data, auth)
  presentation/
    screens/       # Feature screens: home, courses, blog, contact, settings, auth
    widgets/       # Reusable UI components and home-page sections
  main.dart        # App entrypoint and root widget
```

### Key Files

- `main.dart` – wraps the app in `ProviderScope` and wires the global theme + `MainNavigation`
- `core/app_theme.dart` – defines `AppColors` and `AppTheme.lightTheme`
- `data/models.dart` – `Course`, `Category`, `Testimonial`, `BlogPost`
- `data/providers.dart` – mock `coursesProvider`, `categoriesProvider`, `testimonialsProvider`, `blogsProvider`
- `data/auth_provider.dart` – `AppUser`, `AuthState`, and global `authProvider`
- `presentation/screens/home_screen.dart` – main marketing and discovery screen
- `presentation/screens/courses_screen.dart` – filterable course catalog
- `presentation/screens/blog_screen.dart` – blog list
- `presentation/screens/contact_screen.dart` – contact details + form
- `presentation/screens/settings_screen.dart` – account & preferences
- `presentation/screens/main_navigation.dart` – bottom nav shell
- `presentation/widgets/components.dart` – shared components (`SectionHeader`, `CourseCard`, `StatItem`, `CategoryItem`, `BlogCard`)
- `presentation/widgets/popular_courses.dart`, `blog_section.dart`, `category_section.dart` – home-page sections

---

## Tech Stack

- **Framework**: Flutter
- **State Management**: Riverpod (`flutter_riverpod`)
- **Styling**: Custom theme + `google_fonts`

---

## Running the App

From the `risetechpreneur` directory:

```bash
flutter pub get
flutter run
```

The app runs on Android, iOS, web, and desktop (where supported by your Flutter setup).

---

## Next Steps / Integration Points

- Replace mock data providers in `data/providers.dart` with real API or backend calls
- Hook up real authentication in `data/auth_provider.dart` (e.g., Firebase Auth)
- Implement the `CourseDetail` screen and wire it from course cards
- Connect the contact form to a backend or email service
