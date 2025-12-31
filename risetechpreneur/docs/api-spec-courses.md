# RiseTechpreneur Mobile App - Courses API Specification

**Version:** 1.0  
**Date:** December 21, 2025  
**Base URL:** `https://rise-techpreneur.havanacademy.com/api`

---

## Overview

This document defines the API endpoints required by the RiseTechpreneur mobile app for the Courses feature. The mobile app is built with Flutter and uses these endpoints to display course listings, categories, and course details.

---

## 1. Categories

### GET `/api/categories`

Returns all available course categories for filtering.

#### Response

```json
{
  "success": true,
  "data": [
    {
      "id": "1",
      "name": "Design",
      "icon": "🎨",
      "courses_count": 120
    },
    {
      "id": "2",
      "name": "Development",
      "icon": "💻",
      "courses_count": 250
    },
    {
      "id": "3",
      "name": "Marketing",
      "icon": "📢",
      "courses_count": 80
    }
  ]
}
```

#### Field Definitions

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | string | Yes | Unique identifier |
| `name` | string | Yes | Display name (used for filtering) |
| `icon` | string | Yes | Emoji or icon identifier |
| `courses_count` | integer | Yes | Number of courses in this category |

---

## 2. Courses List

### GET `/api/courses`

Returns a list of courses with optional filtering and pagination.

#### Query Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `category` | string | - | Filter by category name (e.g., `Marketing`) |
| `popular` | boolean | false | Return only featured/popular courses |
| `page` | integer | 1 | Page number for pagination |
| `limit` | integer | 20 | Number of items per page |
| `search` | string | - | Search by title |

#### Example Requests

```
GET /api/courses
GET /api/courses?category=Marketing
GET /api/courses?popular=true&limit=6
GET /api/courses?page=2&limit=10
```

#### Response

```json
{
  "success": true,
  "data": [
    {
      "id": "1",
      "title": "Digital Marketing Master Class",
      "subtitle": "Ignite Ethiopia's Digital Future—One Brand at a Time",
      "category": "Marketing",
      "image_url": "https://rise-techpreneur.havanacademy.com/storage/courses/course-1.jpg",
      "rating": 4.8,
      "duration": "10h 30m",
      "price": 89.99
    },
    {
      "id": "2",
      "title": "Flutter Development Bootcamp",
      "subtitle": "Build beautiful cross-platform apps",
      "category": "Development",
      "image_url": "https://rise-techpreneur.havanacademy.com/storage/courses/course-2.jpg",
      "rating": 4.9,
      "duration": "42h 00m",
      "price": 129.99
    }
  ],
  "meta": {
    "current_page": 1,
    "last_page": 5,
    "per_page": 20,
    "total": 98
  }
}
```

#### Field Definitions

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | string | Yes | Unique identifier |
| `title` | string | Yes | Course title (max 100 chars recommended) |
| `subtitle` | string | No | Short description or tagline |
| `category` | string | Yes | Category name (must match categories endpoint) |
| `image_url` | string | Yes | Full URL to course thumbnail (recommended: 600x400px) |
| `rating` | decimal | Yes | Average rating (0.0 - 5.0) |
| `duration` | string | Yes | Formatted duration (e.g., "10h 30m") |
| `price` | decimal | Yes | Course price |

---

## 3. Course Detail

### GET `/api/courses/{id}`

Returns full details for a single course.

#### Response

```json
{
  "success": true,
  "data": {
    "id": "1",
    "title": "Digital Marketing Master Class",
    "subtitle": "Ignite Ethiopia's Digital Future—One Brand at a Time",
    "description": "Full course description with HTML or markdown content...",
    "category": "Marketing",
    "image_url": "https://rise-techpreneur.havanacademy.com/storage/courses/course-1.jpg",
    "rating": 4.8,
    "duration": "10h 30m",
    "price": 89.99,
    "instructor": {
      "id": "101",
      "name": "John Doe",
      "avatar_url": "https://rise-techpreneur.havanacademy.com/storage/instructors/john.jpg",
      "bio": "Senior Marketing Consultant with 10+ years experience"
    },
    "syllabus": [
      {
        "id": "m1",
        "title": "Introduction to Digital Marketing",
        "duration": "1h 30m",
        "lessons_count": 5
      },
      {
        "id": "m2",
        "title": "Social Media Marketing",
        "duration": "2h 00m",
        "lessons_count": 8
      }
    ],
    "reviews_count": 150,
    "enrolled_count": 1200,
    "created_at": "2025-01-15T10:00:00Z",
    "updated_at": "2025-12-01T14:30:00Z"
  }
}
```

#### Additional Fields for Detail View

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `description` | string | Yes | Full course description (HTML/markdown) |
| `instructor` | object | Yes | Instructor information |
| `instructor.id` | string | Yes | Instructor unique ID |
| `instructor.name` | string | Yes | Instructor display name |
| `instructor.avatar_url` | string | No | Instructor profile image URL |
| `instructor.bio` | string | No | Short instructor bio |
| `syllabus` | array | No | List of course modules |
| `syllabus[].id` | string | Yes | Module unique ID |
| `syllabus[].title` | string | Yes | Module title |
| `syllabus[].duration` | string | Yes | Module duration |
| `syllabus[].lessons_count` | integer | Yes | Number of lessons in module |
| `reviews_count` | integer | No | Total number of reviews |
| `enrolled_count` | integer | No | Total enrolled students |
| `created_at` | datetime | No | ISO 8601 timestamp |
| `updated_at` | datetime | No | ISO 8601 timestamp |

---

## 4. Error Responses

All endpoints should return consistent error responses:

```json
{
  "success": false,
  "message": "Course not found",
  "error_code": "COURSE_NOT_FOUND"
}
```

### HTTP Status Codes

| Code | Description |
|------|-------------|
| 200 | Success |
| 400 | Bad Request (invalid parameters) |
| 401 | Unauthorized (token required) |
| 404 | Resource not found |
| 422 | Validation error |
| 500 | Server error |

---

## 5. Authentication

For public course browsing, no authentication is required.

For enrolled courses or user-specific data, include the Bearer token:

```
Authorization: Bearer {token}
```

---

## Notes for Backend Team

1. **Image URLs** should be absolute URLs, not relative paths
2. **Category names** in courses must exactly match the names from `/api/categories` for filtering to work
3. **Duration format** should be consistent (e.g., "10h 30m" or "10:30:00")
4. **Rating** should be a decimal between 0.0 and 5.0
5. **Pagination** meta is optional but recommended for large datasets

---

## Contact

For questions about this spec, contact the mobile development team.
