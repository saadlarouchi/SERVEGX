# SERVEGX — Infrastructure Monitoring & Observability Platform

SERVEGX is a modern, real-time infrastructure monitoring, server health observability, and DevOps incident management platform built with Flutter.

---

## 🚀 Key Features

* **Real-Time Telemetry & Resource Tracking**: Live CPU, Memory, Disk, and Network bandwidth utilization graphs with peak indicators.
* **Dual Design System**: Tailored Dark & Light enterprise themes built with high-contrast, accessible token architecture.
* **Server & Project Management**: Multi-server infrastructure grouping, health checks, incident logs, and status dashboards.
* **Incident Alerting & Notification Center**: Real-time notifications, threshold monitoring, and severity management.
* **Cross-Platform**: First-class support for **Web**, **Android**, and **Windows**.
* **SEO Optimized**: Complete metadata, Open Graph cards, Twitter/X cards, canonical URLs, JSON-LD Schema.org structured data, and search engine crawlers support (`robots.txt`, `sitemap.xml`).

---

## 🛠️ Tech Stack & Architecture

* **Framework**: Flutter 3.x / Dart 3.x
* **State Management**: Provider
* **Design & Theme**: Custom enterprise Design System (`AppColors`, `AppTheme`, `AppDimensions`) supporting seamless runtime light/dark transitions
* **Storage**: `shared_preferences` for theme and preference persistence
* **Routing**: Declarative route registry (`AppRoutes`)

---

## 💻 Getting Started

### Prerequisites

* Flutter SDK (3.24.0 or newer recommended)
* Chrome (for Web) or Android SDK / Visual Studio C++ (for native targets)

### Setup & Run

1. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

2. **Run on Web**:
   ```bash
   flutter run -d chrome
   ```

3. **Run on Windows**:
   ```bash
   flutter run -d windows
   ```

4. **Run on Android**:
   ```bash
   flutter run -d android
   ```

### Quality Assurance & Builds

* **Lint & Analyze**:
  ```bash
  flutter analyze
  ```

* **Run Tests**:
  ```bash
  flutter test
  ```

* **Compile Web Release**:
  ```bash
  flutter build web --release
  ```

---

## 📄 License

Proprietary — SERVEGX Platform. All rights reserved.
