 <p align="center">
  <img src="assets/orchid-banner.jpg" width="100%" alt="Orchid — Flower & Bouquet Platform" />
</p>

<h1 align="center">🌸 Orchid</h1>

<p align="center">
  <strong>A Modern Flower & Bouquet Ordering Platform</strong>
  <br />
  Discover beautiful floral arrangements, create memorable moments, and manage every order through a seamless digital experience.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white" alt="Supabase" />
  <img src="https://img.shields.io/badge/Architecture-Monorepo-6C63FF?style=for-the-badge" alt="Monorepo" />
</p>

<p align="center">
  <a href="#-overview">Overview</a> •
  <a href="#-applications">Applications</a> •
  <a href="#-features">Features</a> •
  <a href="#-tech-stack">Tech Stack</a> •
  <a href="#-project-structure">Project Structure</a> •
  <a href="#-getting-started">Getting Started</a>
</p>

---

## 🌷 Overview

**Orchid** is a multi-platform flower and bouquet ordering solution designed to deliver a smooth shopping experience for customers while providing administrators with the tools to manage products, orders, and inspirational floral content.

Built with **Flutter** and powered by **Supabase**, Orchid brings mobile shopping, web ordering, and administrative operations together in a unified monorepo.

The project consists of three applications:

- 📱 **Orchid Mobile** — A mobile shopping experience for customers.
- 🌐 **Orchid Web** — A web-based shopping experience for customers.
- 🛠️ **Orchid Admin** — An administrative dashboard for managing the platform.

## 🚀 Applications

### 📱 Orchid Mobile

A Flutter mobile application that allows customers to explore floral products and manage their shopping experience.

**Key capabilities:**
- Browse products and bouquet collections.
- Explore floral inspiration.
- Manage the shopping cart and checkout flow.
- Place and track orders.
- Manage profiles and favorites.

### 🌐 Orchid Web

A Flutter Web application that brings the customer shopping experience to the browser.

**Key capabilities:**
- Browse products and bouquets.
- Explore inspiration and featured arrangements.
- Manage orders and shopping activities.
- Access a responsive web interface.

🔗 **Live Website:** [Orchid Web](https://orchid-orchidweb.vercel.app/)

### 🛠️ Orchid Admin

A dedicated Flutter Web dashboard for administrative operations.

**Key capabilities:**
- Secure administrator authentication.
- Dashboard and management workflows.
- Product and bouquet management.
- Order management.
- Inspiration content management.

🔗 **Admin Dashboard:** [Orchid Admin](https://orchid-admin.vercel.app/)

> **Note:** The live URLs above are deployment addresses and may change as domains are configured.

## ✨ Features

- 🌹 **Product Catalog** — Discover floral arrangements and bouquets.
- 💐 **Floral Inspiration** — Explore curated inspiration and floral content.
- 🛒 **Shopping Experience** — Manage cart and checkout workflows.
- 📦 **Order Management** — Place orders and review order history.
- ❤️ **Favorites & Profiles** — Personalize the customer experience.
- 🛠️ **Admin Dashboard** — Manage products, orders, and inspiration.
- 🔄 **Shared Backend** — Centralized backend services powered by Supabase.
- 📱 **Cross-Platform Development** — Flutter-based applications for mobile and web.

## 🧰 Tech Stack

| Technology | Purpose |
|---|---|
| Flutter | Cross-platform application development |
| Dart | Application programming language |
| Supabase | Backend services, database, and authentication |
| PostgreSQL | Relational database |
| Supabase Edge Functions | Server-side operations |
| Supabase Migrations | Database schema and policy management |
| Vercel | Web application deployment |
| Git & GitHub | Version control and source management |

## 🏗️ Project Structure

```text
orchid/
├── orchid_mobile/          # Flutter mobile application
│   └── supabase/           # Supabase migrations and Edge Functions
│
├── orchid_web/             # Flutter Web customer application
│   ├── lib/
│   ├── test/
│   └── build.sh
│
├── orchid_admin/           # Flutter Web admin dashboard
│   ├── lib/
│   └── build.sh
│
├── .gitignore
└── README.md
```

Each application maintains its own Flutter codebase while the repository keeps the overall platform and its backend resources organized in one place.

## ⚙️ Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- Dart SDK compatible with your Flutter installation
- A configured Supabase project
- Git

### 1. Clone the Repository

```bash
git clone https://github.com/20Mahmoud06/orchid.git
cd orchid
```

### 2. Choose an Application

Navigate to the application you want to run:

```bash
cd orchid_mobile
```

Or:

```bash
cd orchid_web
```

Or:

```bash
cd orchid_admin
```

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Configure Environment Variables

Applications that require Supabase configuration should receive the appropriate project URL and publishable key through their supported configuration mechanism.

For example, the Admin application can be run locally with:

```bash
flutter run -d chrome --web-port 8080 \
  --dart-define=SUPABASE_URL=YOUR_SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=YOUR_SUPABASE_PUBLISHABLE_KEY
```

Replace the placeholders with your own Supabase project values.

**Security:** Never commit secret keys, service-role keys, passwords, or private credentials. Public client keys must be used with properly configured Row Level Security (RLS) policies.

### 5. Run the Application

For mobile development:

```bash
flutter run
```

For web development:

```bash
flutter run -d chrome
```

Follow each application's configuration requirements before running it.

## 🌍 Deployment

Orchid's web applications can be deployed independently through Vercel while sharing the same GitHub repository.

| Application | Root Directory | Build Command | Output Directory |
|---|---|---|---|
| Orchid Web | `orchid_web` | `bash build.sh` | `build/web` |
| Orchid Admin | `orchid_admin` | `bash build.sh` | `build/web` |

Configure the required environment variables in the corresponding Vercel project before building applications that depend on them.

## 🔐 Security

- Keep private credentials outside source control.
- Store server-side secrets in secure environment variables.
- Use Supabase Row Level Security to protect database records.
- Validate privileged operations on the server side.
- Never expose `service_role` keys or `sb_secret_` keys in client applications.

## 🖼️ Screenshots

Screenshots and application previews will be added here.

<!-- Add application screenshots below when available. -->

## 🗺️ Roadmap

- [ ] Add the final project banner and application screenshots.
- [ ] Document each application in its own README.
- [ ] Expand setup and deployment documentation.
- [ ] Continue improving the customer shopping experience and administrative workflows.

## 👨‍💻 Author

**Mahmoud Safa**

<p>
  <a href="https://github.com/20Mahmoud06">
    <img src="https://img.shields.io/badge/GitHub-20Mahmoud06-181717?style=for-the-badge&logo=github" alt="GitHub Profile" />
  </a>
  <a href="https://linktr.ee/mahmoudsafa220">
    <img src="https://img.shields.io/badge/Linktree-Connect-43E55E?style=for-the-badge&logo=linktree&logoColor=white" alt="Linktree" />
  </a>
</p>

---

<p align="center">
  Built with 💜 using Flutter and Supabase.
  <br />
  <strong>Orchid — Every flower tells a story.</strong>
</p>
