# RiseTechpreneur – Mobile App

**RiseTechpreneur** is a cross-platform Flutter learning application designed for aspiring tech entrepreneurs in Ethiopia. The app features a modern course catalog, blog content, user authentication, and a polished mobile-first UI built with Riverpod state management and a custom design system.

---

## 🚀 Features

### **Authentication & User Management**

- ✅ **Full Auth Flow** – Sign-in, sign-up, and logout
- ✅ **Real API Integration** – Connected to `https://rise-techpreneur.havanacademy.com/api`
- ✅ **Secure Storage** – JWT tokens stored securely with `flutter_secure_storage`
- ✅ **Password Management** – Forgot password, reset password, and update password
- ✅ **Session Persistence** – Auto-login on app restart
- ✅ **Deep Linking** – Password reset via `risetechpreneur://reset-password` links

### **Home Screen**

- Hero section with CTA and key statistics
- Popular courses horizontal carousel
- Course categories grid (12 categories)
- Auto-scrolling testimonials (3 testimonials, 6-second intervals)
- Blog section preview
- Responsive footer with social links
- Auth-gated enrollment (redirects to login for unauthenticated users)

### **Courses**

- Browse all courses in a responsive grid layout
- Horizontally scrollable category filter chips
- "All" category to view entire catalog
- Real-time filtering by selected category
- Course cards with ratings, duration, and enrollment buttons
- Paid-course enrollment supports uploading payment proof (transaction screenshot) (PNG/JPG/JPEG, <= 5MB)
- iOS requires photo library permission text (`NSPhotoLibraryUsageDescription`)

### **Blog**

- Curated blog posts for entrepreneurs
- Reusable `BlogCard` component
- Date and read-time metadata

### **Contact**

- Quick action cards (Email, Phone, Address)
- Contact form with validation
- Email integration via `url_launcher`

### **More Options**

- Events (workshops & webinars) – _placeholder_
- Terms of Service – _placeholder_
- Privacy Policy – _placeholder_
- App Settings – _placeholder_

### **Settings**

- User profile display
- Account management options – _placeholder_
- Logout functionality

### **Navigation**

- Custom bottom navigation bar with 5 tabs
- `IndexedStack` for state preservation across tabs
- Smooth navigation with Material Design transitions

---

## 📁 Project Structure

```
lib/
├── core/                          # Theme, colors, constants & utilities
│   ├── app_theme.dart            # AppColors & AppTheme (Inter font)
│   ├── constants.dart            # Global constants (placeholder)
│   └── utils.dart                # Utility functions (placeholder)
│
├── data/                         # Domain models & state providers
│   ├── models.dart               # Course, Category, Testimonial, BlogPost
│   ├── providers.dart            # Mock data providers (7 courses, 12 categories)
│   └── auth_provider.dart        # AuthState, API integration, secure storage
│
├── presentation/
│   ├── screens/                  # Feature screens
│   │   ├── main_navigation.dart  # Bottom nav shell with IndexedStack
│   │   ├── home_screen.dart      # Main landing page
│   │   ├── courses_screen.dart   # Filterable course catalog
│   │   ├── blog_screen.dart      # Blog list
│   │   ├── contact_screen.dart   # Contact form & quick actions
│   │   ├── more_screen.dart      # Additional menu options
│   │   ├── settings_screen.dart  # Account & preferences
│   │   ├── auth_screen.dart      # Tabbed sign-in/sign-up
│   │   ├── reset_password_screen.dart  # Password reset via deep link
│   │   └── course_detail.dart    # Placeholder for course details
│   │
│   └── widgets/                  # Reusable UI components
│       ├── components.dart       # SectionHeader, CourseCard, StatItem, etc.
│       ├── blog_posts.dart       # BlogCard widget
│       ├── blog_section.dart     # Home page blog section
│       ├── category_section.dart # Home page category grid
│       ├── popular_courses.dart  # Home page courses carousel
│       └── input_fields.dart     # Custom inputs (placeholder)
│
├── repositories/                 # Future data layer (currently empty)
│
└── main.dart                     # App entrypoint with ProviderScope & deep linking
```

---

## 🛠️ Tech Stack

| Component            | Technology             | Version                                         |
| -------------------- | ---------------------- | ----------------------------------------------- |
| **Framework**        | Flutter                | SDK ≥3.7.2                                      |
| **State Management** | Riverpod               | 3.0.3                                           |
| **Typography**       | Google Fonts (Inter)   | 6.3.2                                           |
| **HTTP Client**      | http                   | 1.6.0                                           |
| **Secure Storage**   | flutter_secure_storage | 9.2.4                                           |
| **Deep Linking**     | app_links              | 6.4.1                                           |
| **URL Launcher**     | url_launcher           | 6.3.2                                           |
| **Backend API**      | REST API               | `https://rise-techpreneur.havanacademy.com/api` |

---

## 🎨 Design System

### **Color Palette**

```dart
Primary Blue:    #155DFC  // Buttons, active states
Secondary Navy:  #1E293B  // Headers, dark text
Text Grey:       #64748B  // Body text, subtitles
Background:      #F8FAFC  // Light grey background
Accent Yellow:   #FBBF24  // Star ratings
```

### **Typography**

- **Font Family**: Inter (via Google Fonts)
- **Display Large**: 32px, 800 weight
- **Display Medium**: 24px, 700 weight
- **Title Medium**: 18px, 600 weight
- **Body Large**: 16px, 400 weight
- **Body Medium**: 14px, 400 weight

---

## 🔐 Authentication

### **API Endpoints**

- `POST /login-user` – Sign in with email/password
- `POST /create-user` – User registration
- `POST /logout-user` – Sign out
- `POST /password/reset/request` – Request password reset email
- `POST /password/reset` – Reset password with token
- `POST /password/update` – Update password (authenticated)

### **Validation Rules**

- **Email**: Standard email format
- **Phone**: Ethiopian format (+251XXXXXXXXX)
- **Password**: Minimum 6 characters
- **Confirm Password**: Must match password

### **Secure Storage**

The app stores the following in encrypted storage:

- `auth_token` – JWT token for API requests
- `auth_email` – User email
- `auth_first_name` – User first name
- `auth_last_name` – User last name

### **Deep Link Support**

Password reset links:

```
risetechpreneur://reset-password?token=<TOKEN>&email=<EMAIL>
```

---

## 🚀 Getting Started

### **Prerequisites**

- Flutter SDK (≥3.7.2)
- Dart SDK
- Android Studio / Xcode (for mobile development)
- VS Code or Android Studio with Flutter plugins

### **Installation**

1. **Clone the repository**

   ```bash
   git clone <repository-url>
   cd risetechpreneur
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### **Platform-Specific Setup**

#### **Android**

- Firebase configured with Project ID: `rise-tech-121`
- App ID: `1:688006449226:android:166334a8c93ff211a63eb3`

#### **iOS**

- Firebase configured
- App ID: `1:688006449226:ios:61fb716e3a2cb020a63eb3`

#### **Web & Desktop**

- Basic support enabled
- No additional configuration required

---

## 📊 Current Data Status

### **✅ API-Integrated**

- User authentication (login, signup, logout)
- Password management (reset, update)
- Session persistence

### **⚠️ Mock Data** (Hardcoded Providers)

- **Courses**: 7 sample courses
- **Categories**: 12 categories (Design, Programming, Marketing, etc.)
- **Testimonials**: 3 user testimonials
- **Blog Posts**: 3 sample blog articles

---

## 🔄 Navigation Flow

```
App Launch → MainNavigation (Bottom Nav)
  ├─ Home (Tab 0)
  │  ├─ View Courses
  │  ├─ Browse Categories
  │  └─ Enroll (→ Auth if not logged in)
  │
  ├─ Courses (Tab 1)
  │  ├─ Filter by Category
  │  └─ View Course Details (not implemented)
  │
  ├─ Blog (Tab 2)
  │
  ├─ Contact (Tab 3)
  │  └─ Send Email
  │
  └─ More (Tab 4)
     ├─ Events (placeholder)
     ├─ Terms (placeholder)
     ├─ Privacy (placeholder)
     └─ Settings (placeholder)

Deep Links:
  └─ risetechpreneur://reset-password → ResetPasswordScreen
```

---

## 🎯 Next Steps

### **High Priority**

1. **Replace Mock Data** – Connect `coursesProvider`, `categoriesProvider`, `testimonialsProvider`, and `blogsProvider` to real API endpoints
2. **Implement Course Detail Screen** – Complete `course_detail.dart` with course information, curriculum, reviews, and enrollment
3. **Add Loading States** – Show loading indicators during API calls
4. **Error Handling** – Implement retry mechanisms and user-friendly error messages

### **Medium Priority**

5. **Complete More Screen Options** – Implement Events, Terms of Service, and Privacy Policy pages
6. **User Profile Editing** – Allow users to update profile information
7. **Course Enrollment Flow** – Integrate payment or registration system
8. **Search Functionality** – Add search for courses and blogs
9. **Testing** – Unit tests for auth logic, widget tests for screens

### **Low Priority**

10. **Offline Support** – Cache data for offline viewing
11. **Push Notifications** – Notify users of new courses and updates
12. **Analytics** – Track user behavior and engagement
13. **Accessibility** – Improve screen reader support and touch targets
14. **Performance Optimization** – Image caching, lazy loading

---

## 🧪 Testing

### **Current Status**

- Test directory exists: `test/`
- Standard widget test template present
- **No custom tests implemented yet**

### **Recommended Tests**

- Unit tests for `AuthState` methods
- Widget tests for authentication flow
- Integration tests for navigation
- API mock tests for data providers

---

## 📝 Known Issues

1. **Placeholders**: Several screens have placeholder implementations (Events, Terms, Privacy, App Settings)
2. **Mock Data**: Courses, categories, testimonials, and blogs are hardcoded
3. **Course Detail**: Screen exists but not implemented
4. **More Screen Navigation**: Tap handlers are empty
5. **Settings Preferences**: Only logout is functional

---

## 🤝 Contributing

This project uses Flutter best practices:

- **State Management**: Riverpod for reactive state
- **Architecture**: Feature-based organization
- **Theming**: Centralized design system
- **Code Style**: Follow Dart style guide

---

## 📄 License

_Add your license information here_

---

## 👥 Team

**RiseTechpreneur** – Empowering Ethiopian Tech Entrepreneurs

For questions or support, use the Contact screen in the app or visit:

- **Website**: https://rise-techpreneur.havanacademy.com
- **Email**: info@risetechpreneur.com _(update with actual contact)_

---

**Last Updated**: December 10, 2025
