<p align="center">
  <img src="assets/orchid-web-banner.jpg" width="100%" alt="Orchid Web — Flower & Bouquet Shopping Platform" />
</p>

<h1 align="center">🌸 Orchid Web</h1>

<p align="center">
  <strong>Discover Flowers. Find Inspiration. Order Beautifully.</strong><br />
  A modern, responsive flower and bouquet shopping experience built with Flutter Web.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white" alt="Supabase" />
  <img src="https://img.shields.io/badge/Platform-Flutter%20Web-6C63FF?style=for-the-badge" alt="Flutter Web" />
  <img src="https://img.shields.io/badge/Deployment-Vercel-black?style=for-the-badge&logo=vercel&logoColor=white" alt="Vercel" />
</p>

---

## 🔗 Live Demo

Experience the platform directly in your browser:
**[🌐 Orchid Web — Live Website](https://orchid-orchidweb.vercel.app/#/main-nav)**

---

## 🌷 Overview

**Orchid Web** is the browser-based customer experience within the Orchid platform. It brings floral products, bouquet inspiration, and order-related functionality into a responsive web application.

Built with **Flutter Web** and integrated with **Supabase**, the application aims to provide a consistent shopping experience across desktop and mobile browsers.

The project is maintained as part of the Orchid monorepo, alongside the Orchid Mobile application and Orchid Admin dashboard.

## ✨ Features

### 💐 Floral Product Discovery

- Browse floral products and bouquet arrangements.
- Explore product imagery and available information.
- Discover curated floral content through a dedicated inspiration experience.

### 🌸 Inspiration

- Explore floral inspiration and arrangement ideas.
- Browse visual content through dedicated web widgets.
- Navigate inspiration content in a layout designed for larger screens and responsive browser windows.

### 📦 Order History

- Access the order history experience.
- Review available order information and status details.
- Use a dedicated web layout for presenting order-related content.

### 🖥️ Responsive Web Experience

- Flutter-powered interface rendered in the browser.
- Layouts designed for different viewport sizes.
- Dedicated web widgets for selected screens.
- Reusable UI components for consistent styling and behavior.

### 🔗 Backend Integration

- Supabase connectivity for supported application features.
- Authentication and data access where configured.
- Shared backend infrastructure within the Orchid ecosystem.

> The availability of checkout, authentication, product management, and other workflows depends on the current implementation and backend configuration.

## 🧰 Tech Stack

| Technology              | Purpose                                 |
| ----------------------- | --------------------------------------- |
| Flutter Web             | Browser-based application UI            |
| Dart                    | Application programming language        |
| Supabase                | Backend services and authentication     |
| PostgreSQL              | Relational data storage                 |
| Supabase Edge Functions | Server-side operations where configured |
| Vercel                  | Web deployment and hosting              |
| Git & GitHub            | Version control and source management   |

## 🏗️ Project Structure

```text
orchid_web/
├── lib/
│   ├── features/
│   │   ├── inspiration/
│   │   │   ├── cubit/
│   │   │   ├── models/
│   │   │   └── view/
│   │   │       ├── screens/
│   │   │       └── widgets/
│   │   │           └── web/
│   │   └── order/
│   │       ├── cubit/
│   │       └── view/
│   │           ├── screens/
│   │           └── widgets/
│   │               └── web/
│   └── ...
│
├── test/
│   ├── inspiration_web_layout_test.dart
│   └── order_history_web_layout_test.dart
│
├── web/
├── assets/
├── build.sh
├── pubspec.yaml
└── README.md
```

> This is a representative structure based on the current feature organization; other application files and shared components may exist.

## ⚙️ Getting Started

### Prerequisites

Install the following tools before running the application:

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Dart SDK](https://dart.dev/get-dart) compatible with the installed Flutter version
- Google Chrome or another supported browser
- Git
- Access to the configured Supabase project, if required by the features being tested

### 1. Clone the Repository

Orchid Web is part of a monorepo:

```bash
git clone https://github.com/20Mahmoud06/orchid.git
cd orchid/orchid_web
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Configure Supabase

If the application requires Supabase configuration, supply the project URL and publishable key through Dart compile-time environment variables.

```bash
flutter run -d chrome \
  --dart-define=SUPABASE_URL=YOUR_SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=YOUR_SUPABASE_PUBLISHABLE_KEY
```

Replace the placeholders with the appropriate values for your own Supabase project.

**Security notes:** Do not commit private credentials or expose `service_role` or `sb_secret_` keys in client-side applications. Ensure appropriate Row Level Security (RLS) policies protect database records.

### 4. Run the Web Application

```bash
flutter run -d chrome
```

To run the application on a specific local port:

```bash
flutter run -d chrome --web-port 8080
```

If the app requires Supabase configuration, include the required `--dart-define` arguments when launching it.

## 🧪 Testing & Code Quality

Run Flutter static analysis:

```bash
flutter analyze
```

Run the test suite:

```bash
flutter test
```

Run an individual layout test when needed:

```bash
flutter test test/inspiration_web_layout_test.dart
flutter test test/order_history_web_layout_test.dart
```

These tests help validate the implemented UI behavior and layouts.

## 🏗️ Production Build

Create an optimized Flutter Web release build:

```bash
flutter build web --release
```

Flutter generates the static web output in:

```text
build/web/
```

The generated directory contains the assets and entry files required to serve the compiled web application.

## 🚀 Deployment with Vercel

Orchid Web is configured for deployment from the Orchid monorepo.

### Vercel Project Settings

| Setting               | Value              |
| --------------------- | ------------------ |
| **Git Repository**    | 20Mahmoud06/orchid |
| **Root Directory**    | orchid_web         |
| **Framework Preset**  | Other              |
| **Build Command**     | bash build.sh      |
| **Output Directory**  | build/web          |
| **Install Command**   | *Leave blank*      |

### Environment Variables

If the application uses Supabase at build time, configure the required variables in the Vercel project settings:

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`

Select the appropriate deployment environments and ensure the values match the intended Supabase project.

> **Note:** Do not hardcode keys in `build.sh`. The build script should read the configured environment variables and pass them to Flutter through `--dart-define`.

### Automatic Deployment

When the repository is connected to Vercel, pushing a commit to the configured production branch can trigger a new deployment automatically.

```bash
git add orchid_web/
git commit -m "update: improve web experience"
git push origin main
```

> Run these Git commands from the repository root, not from inside `orchid_web`.

After pushing, check the Vercel deployment status and verify the production site once the build completes.

## 🔐 Security

- Use only client-safe publishable keys in browser applications.
- Never expose Supabase service-role or secret keys in compiled Flutter Web assets.
- Configure Row Level Security (RLS) for exposed database tables.
- Enforce permissions on the backend rather than relying only on UI restrictions.
- Keep deployment configuration and credentials out of source control.

## 🌍 Part of the Orchid Platform

Orchid Web is one of three applications in the Orchid ecosystem:

- 📱 **Orchid Mobile** — A customer-facing mobile application.
- 🌐 **Orchid Web** — The browser-based shopping experience.
- 🛠️ **Orchid Admin** — The administrative dashboard.

Explore the complete project:

[Orchid — GitHub Repository](https://github.com/20Mahmoud06/orchid)

## 👨‍💻 Author

**Mahmoud Safa**

<p>
  <a href="https://github.com/20Mahmoud06">
    <img src="https://img.shields.io/badge/GitHub-20Mahmoud06-181717?style=for-the-badge&logo=github" alt="GitHub Profile" />
  </a>
  <a href="https://linktr.ee/ORCHID_Flowers">
    <img src="https://img.shields.io/badge/Linktree-Connect-43E55E?style=for-the-badge&logo=linktree&logoColor=white" alt="Linktree" />
  </a>
</p>

---

<p align="center">
  Built with 💜 using Flutter and Supabase.<br />
  <strong>Orchid Web — Let every flower find its moment.</strong>
</p>
