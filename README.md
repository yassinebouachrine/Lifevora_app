<h1 align="center">
  🏃 Lifevora
</h1>

<p align="center">
  <strong>A full-stack fitness & well-being tracker built with Flutter + Node.js</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Node.js-20.x-339933?style=for-the-badge&logo=node.js&logoColor=white" alt="Node.js" />
  <img src="https://img.shields.io/badge/MySQL-8.x-4479A1?style=for-the-badge&logo=mysql&logoColor=white" alt="MySQL" />
  <img src="https://img.shields.io/badge/Express.js-4.x-000000?style=for-the-badge&logo=express&logoColor=white" alt="Express" />
</p>

---

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Environment Variables](#environment-variables)
- [API Reference](#api-reference)
- [Contributing](#contributing)
- [License](#license)

---

## Overview

**Lifevora** is a cross-platform fitness and well-being mobile application that helps users track their workouts, monitor weekly progress, manage their health profile, and stay motivated through an immersive metaverse gym experience. The project follows a monorepo structure with a Flutter frontend and a Node.js/Express REST API backend backed by MySQL.

---

## Features

- 🔐 **Authentication** — Register, login, JWT-based session management, password change
- 🏋️ **Activity Tracking** — Log runs, walks, cycling, yoga, swimming, and weight training
- 📊 **Statistics Dashboard** — Weekly and long-term progress charts powered by `fl_chart`
- 👤 **Profile & Onboarding** — Personalized fitness goals, body metrics, activity level
- 🌐 **Virtual Gym (Metaverse)** — Immersive 3D environment with avatar and mood system
- 🤖 **Smart Coach** — AI-driven coaching screen
- 🍎 **Food Scanner** — Nutrition tracking integration
- 🕓 **Activity History** — Searchable, filterable log of past sessions
- ⚙️ **Settings** — Theme mode, notifications, and account management

---

## Tech Stack

### Frontend

| Package | Purpose |
|---|---|
| `flutter` + `dart` | Cross-platform UI framework |
| `provider` | State management |
| `http` | REST API communication |
| `fl_chart` | Charts & statistics |
| `flutter_animate` | Micro-animations & transitions |
| `google_fonts` | Typography |
| `shared_preferences` | Local token storage |
| `image_picker` | Avatar / photo upload |
| `hugeicons` | Icon library |

### Backend

| Package | Purpose |
|---|---|
| `express` | HTTP server / routing |
| `mysql2` | MySQL database driver |
| `jsonwebtoken` | JWT auth tokens |
| `bcryptjs` | Password hashing |
| `dotenv` | Environment config |
| `cors` | Cross-origin resource sharing |
| `uuid` | Unique ID generation |
| `nodemon` | Hot-reload in development |

---

## Project Structure

```
Lifevora_app/
├── lifevora_frontend/          # Flutter mobile app
│   ├── lib/
│   │   ├── main.dart
│   │   ├── app.dart
│   │   ├── core/
│   │   │   └── services/
│   │   │       └── api_service.dart
│   │   ├── models/
│   │   ├── providers/
│   │   ├── screens/
│   │   │   ├── auth/
│   │   │   ├── home/
│   │   │   ├── add_activity/
│   │   │   ├── history/
│   │   │   ├── profile/
│   │   │   ├── metaverse/
│   │   │   ├── smart_coach/
│   │   │   ├── food_scanner/
│   │   │   ├── onboarding/
│   │   │   └── settings/
│   │   └── widgets/
│   └── pubspec.yaml
│
└── lifevora_backend/           # Node.js REST API
    ├── server.js
    ├── database/
    │   └── schema.sql
    ├── src/
    │   ├── config/
    │   ├── controllers/
    │   ├── middleware/
    │   ├── models/
    │   ├── routes/
    │   └── services/
    └── package.json
```

---

## Prerequisites

Make sure the following are installed on your machine:

- [Flutter SDK](https://docs.flutter.dev/get-started/install) `>=3.0.0`
- [Node.js](https://nodejs.org/) `>=18.x`
- [MySQL Server](https://dev.mysql.com/downloads/mysql/) `8.x`
- Android Studio / Xcode (for running the emulator)

---

## Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/yassinebouachrine/Lifevora_app.git
cd Lifevora_app
```

### 2. Set Up the Backend

```bash
cd lifevora_backend

# Install dependencies
npm install

# Create your environment file (see Environment Variables section)
cp .env.example .env

# Start the development server
npm run dev
```

The API will be running at `http://localhost:3000`. You can verify with:

```
GET http://localhost:3000/health
```

### 3. Set Up the Frontend

Open a **new terminal** in the project root:

```bash
cd lifevora_frontend

# Install Flutter packages
flutter pub get

# Run on emulator or connected device
flutter run
```

> **Note:** If you're running on a physical Android device, update the `_baseUrl` in `lib/core/services/api_service.dart` to point to your machine's local IP address.

---

## Environment Variables

Create a `.env` file inside `lifevora_backend/` based on the following template:

```env
# Server
PORT=3000
NODE_ENV=development

# Database
DB_HOST=localhost
DB_PORT=3306
DB_USER=your_mysql_user
DB_PASSWORD=your_mysql_password
DB_NAME=lifevora_db

# Auth
JWT_SECRET=your_super_secret_jwt_key
JWT_EXPIRES_IN=7d
```


## API Reference

All endpoints are prefixed with `/api`.

### Auth — `/api/auth`

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| `POST` | `/register` | ❌ | Create a new account |
| `POST` | `/login` | ❌ | Login and receive JWT |
| `GET` | `/me` | ✅ | Get current user |
| `POST` | `/logout` | ✅ | Logout session |
| `POST` | `/forgot-password` | ❌ | Initiate password reset |

### Activities — `/api/activities`

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| `GET` | `/` | ✅ | List all activities (paginated, filterable) |
| `GET` | `/:id` | ✅ | Get a single activity |
| `POST` | `/` | ✅ | Create a new activity |
| `PUT` | `/:id` | ✅ | Update an activity |
| `DELETE` | `/:id` | ✅ | Delete an activity |

**Activity types:** `course`, `marche`, `velo`, `yoga`, `natation`, `musculation`

### Stats — `/api/stats`

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| `GET` | `/dashboard` | ✅ | Dashboard summary stats |
| `GET` | `/weekly?weeks=4` | ✅ | Weekly breakdown |

### Profile — `/api/profile`

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| `GET` | `/` | ✅ | Get full profile |
| `PUT` | `/` | ✅ | Update profile fields |
| `POST` | `/complete-onboarding` | ✅ | Submit onboarding data |
| `PUT` | `/change-password` | ✅ | Change password |

---

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Commit your changes: `git commit -m 'feat: add your feature'`
4. Push to the branch: `git push origin feature/your-feature`
5. Open a Pull Request

---

## License

This project is licensed under the **MIT License**.

---


