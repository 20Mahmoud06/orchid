<p align=*center*> <img src=*assets/orchid-mobile-banner.png* width=***100**%* alt=*Orchid Mobile — Flower & Bouquet Shopping App* /> </p>

<h1 align=*center*>🌸 Orchid Mobile</h1>

<p align=*center*>
    <strong>Discover Beauty. Share Emotions. Send Flowers.</strong>
    <br />
    A modern Flutter mobile application for exploring floral arrangements, discovering inspiration, and managing bouquet orders.
</p>

<p align=*center*>
    <img src="[https://img.shields.io/badge/Flutter-**02569B**?style=for-the-badge&logo=flutter&logoColor=white"](https://img.shields.io/badge/Flutter-**02569B**?style=for-the-badge&logo=flutter&logoColor=white*) alt=*Flutter* />
    <img src=*[https://img.shields.io/badge/Dart-**0175C2**?style=for-the-badge&logo=dart&logoColor=white"](https://img.shields.io/badge/Dart-**0175C2**?style=for-the-badge&logo=dart&logoColor=white*) alt=*Dart* />
    <img src=*[https://img.shields.io/badge/Supabase-**3ECF8E**?style=for-the-badge&logo=supabase&logoColor=white"](https://img.shields.io/badge/Supabase-**3ECF8E**?style=for-the-badge&logo=supabase&logoColor=white*) alt=*Supabase* />
    <img src=*[https://img.shields.io/badge/Platform-Android%20%7C%20iOS-**6C63FF**?style=for-the-badge"](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-**6C63FF**?style=for-the-badge*) alt=*Android and iOS* />
</p>

<p align=*center*>
    <a href=*#-overview*>Overview</a> •
    <a href=*#-features*>Features</a> •
    <a href=*#-tech-stack*>Tech Stack</a> •
    <a href=*#-architecture*>Architecture</a> •
    <a href=*#-getting-started">Getting Started</a>
</p>

---

## 🌷 Overview

**Orchid Mobile** is the customer-facing mobile application within the Orchid platform, designed to make discovering and ordering flowers a smooth and enjoyable experience.

Built with **Flutter** and powered by **Supabase**, the application brings product discovery, floral inspiration, and order management together in a mobile-first experience.

Whether customers are looking for a beautiful bouquet, exploring floral ideas, or checking the status of an order, Orchid aims to make every step simple and accessible.

## ✨ Features

### 💐 Product Discovery

- Browse available floral products and bouquet arrangements.
- Explore product details and imagery.
- Discover floral collections and featured items.
- Navigate the catalog through a mobile-friendly interface.

### 🌸 Floral Inspiration

- Explore inspirational floral content.
- Discover bouquet ideas and arrangements.
- Browse visual content designed to help customers find the right flowers for every occasion.

### 🛒 Shopping Experience

- Explore products before placing an order.
- Manage the customer ordering flow.
- Review relevant order information throughout the purchasing journey.

### 📦 Order History

- View previously placed orders.
- Review order details and available status information.
- Keep track of order activity from within the application.

### 👤 Authentication & Account

- Customer authentication powered by Supabase.
- Access customer-specific data through authenticated sessions.
- Keep account-related functionality integrated with the application experience.

### 🎨 User Experience

- Flutter-based cross-platform UI.
- Responsive layouts for different mobile screen sizes.
- Consistent visual styling and reusable interface components.
- Organized screens and state-management logic.

> Feature availability depends on the current application implementation and backend configuration.

## 🧰 Tech Stack

| Technology              | Purpose                                 |
| ----------------------- | --------------------------------------- |
| Flutter                 | Cross-platform mobile UI                |
| Dart                    | Application programming language        |
| Supabase                | Backend services and authentication     |
| PostgreSQL              | Relational database                     |
| Supabase Edge Functions | Server-side operations where configured |
| Supabase Storage        | File and image storage where configured |
| Git & GitHub            | Version control                         |

## 🏗️ Architecture

The application organizes its code by feature, separating presentation, state management, and data-access responsibilities where applicable.

text orchid_mobile/ ├── lib/ │   ├── core/                  # Shared utilities and configuration │   ├── features/ │   │   ├── auth/              # Authentication │   │   ├── order/             # Order-related functionality │   │   └── ...                # Other application features │   └── main.dart              # Application entry point │ ├── supabase/ │   ├── migrations/            # Database migrations │   └── functions/             # Edge Functions, if configured │ ├── assets/                    # Images, icons, and other assets ├── test/                      # Automated tests, if present ├── pubspec.yaml               # Dependencies and asset configuration └── **README**.md The tree above is a high-level illustration; exact folders may vary as the project evolves.

⚙️ Getting Started Prerequisites Before running Orchid Mobile, install:

Flutter **SDK**

Dart **SDK** compatible with your Flutter version

Android Studio or another supported development environment

An Android emulator, iOS simulator on macOS, or a physical device

Access to a configured Supabase project

## Clone the Repository

Clone the Orchid monorepo:

bash git clone [https://github.com/20Mahmoud06/orchid.git](https://github.com/20Mahmoud06/orchid.git) cd orchid/orchid_mobile ## Install Dependencies bash flutter pub get ## Configure Supabase The application uses compile-time configuration for its Supabase connection.

Provide the project **URL** and publishable key through the configuration mechanism used by the app.

Example:

bash
flutter run \
    --dart-define=SUPABASE_URL=YOUR_SUPABASE_URL \
    --dart-define=SUPABASE_ANON_KEY=YOUR_SUPABASE_PUBLISHABLE_KEY
Replace the placeholders with your own project values.

Security notes:

Never commit private credentials or secret keys.

Never expose Supabase service_role or sb_secret_ keys in a mobile application.

Protect database tables with appropriate Row Level Security (**RLS**) policies.

Enforce authorization for privileged operations on the server side.

## Run the Application

Connect a device or start an emulator, then run:

bash flutter run To list available devices:

bash flutter devices To build an Android **APK**:

bash flutter build apk --release The generated **APK** is typically located at:

text build/app/outputs/flutter-apk/app-release.apk For iOS builds, use macOS with the required Xcode toolchain:

bash flutter build ios --release 🧪 Testing & Code Quality Run static analysis:

bash flutter analyze Run automated tests:

bash flutter test These commands help identify code issues and verify the tests included in the project.

🔐 Security Orchid Mobile connects to backend services, so protecting data and enforcing access rules are essential.

Use publishable client keys only in the application.

Enable and validate **RLS** policies for exposed Supabase tables.

Keep privileged operations behind trusted server-side endpoints.

Validate user permissions independently of the client interface.

Avoid logging credentials, tokens, or sensitive user information.

🖼️ Screenshots Application screenshots will be added here to showcase the actual mobile interface.

<!-- Add screenshots of the home screen, product catalog, product details, cart, and order history here. --> 🌍 Part of the Orchid Platform Orchid Mobile is one of three applications in the Orchid ecosystem.

🌐 Orchid Web — The customer-facing web experience.

🛠️ Orchid Admin — The administrative dashboard.

📱 Orchid Mobile — The customer-facing mobile application.

Explore the main repository:

Orchid — GitHub Repository

👨‍💻 Author ### Mahmoud Safa

<p> <a href=*[https://github.com/20Mahmoud06*>](https://github.com/20Mahmoud06*>) <img src=*[https://img.shields.io/badge/GitHub-20Mahmoud06-**181717**?style=for-the-badge&logo=github"](https://img.shields.io/badge/GitHub-20Mahmoud06-**181717**?style=for-the-badge&logo=github*) alt=*GitHub Profile* /> </a> <a href=*[https://linktr.ee/mahmoudsafa220*>](https://linktr.ee/mahmoudsafa220*>) <img src="[https://img.shields.io/badge/Linktree-Connect-**43E55E**?style=for-the-badge&logo=linktree&logoColor=white"](https://img.shields.io/badge/Linktree-Connect-**43E55E**?style=for-the-badge&logo=linktree&logoColor=white*) alt=*Linktree* /> </a> </p> <p align=*center"> Made with 💜 using Flutter and Supabase. <br /> <strong>Orchid Mobile — Make every moment blossom.</strong> </p> ```
