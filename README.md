# 🎓 Aptech IT Support Hub

> **Enterprise Campus IT Helpdesk, Smart Complaint Routing & 2.5D Computer Lab Diagnostic System**  
> Built with **Flutter**, backed by **Google Firebase** (Auth, Cloud Firestore, Firebase Hosting).

---

## 🌐 Live Deployment

* **Production URL:** [https://aptech-it-support.web.app](https://aptech-it-support.web.app)
* **Alternative Domain:** [https://aptech-it-support.firebaseapp.com](https://aptech-it-support.firebaseapp.com)
* **Connected Firebase Project ID:** `aptech-it-support`

---

## 🚀 Key Features

### 1. 🤖 Smart Ticket Engine (NLP & Regex Auto-Detection)
* **Automated Lab Detection:** The complaint parser uses regex to automatically detect room numbers (`101–120`, `201–220`, `JBR Lab`, `IBR Lab`) from natural language messages (e.g. *"Need IT in Lab 102 internet issue"*).
* **Automated Issue Categorization:** Keyword matching maps messages into categories:
  * 🖥 **Hardware:** Mouse, keyboard, monitor, LED, CPU, RAM, screen.
  * 💻 **Software:** VSCode, Android Studio, Lanschool, MongoDB, SQL, crashes.
  * 🌐 **Network:** WiFi, LAN, internet disconnects, ethernet cables.
  * 📝 **Exam:** Safe Exam Browser (SEB), ActiveX, exam portal issues.
  * 🔐 **Access:** Login blocked, admin credentials, password resets.
* **Intelligent Auto-Assignment:** Queries available technicians whose `associatedLabs` array matches the detected lab and routes the complaint immediately.

### 2. 🖥️ 2.5D Isometric Lab Visualizer
* **Isometric Matrix Rendering:** Transforms PC workstation cards into an isometric 2.5D plane using custom `Matrix4` transformations (`rotateX(-0.25)`, `rotateZ(-0.15)`).
* **Live Health Indicators:** 
  * 🟢 **Green:** All hardware, cables, and specifications verified healthy.
  * 🔴 **Red:** At least one hardware fault (e.g., faulty keyboard, loose VGA/LAN cable, low RAM, or failing CPU).
  * ⚪ **Grey:** Inactive / offline workstation.
* **Per-PC Hardware Diagnostic Modal:** Full diagnostic checklist for technicians:
  * Peripherals: Keyboard, Mouse, LED monitor.
  * Cabling: VGA/HDMI, Power, Ethernet LAN.
  * System Specifications: RAM, SSD capacity, Operating System, Custom Notes.

### 3. 💬 Real-Time Chat & Complaint Hub
* Fast, conversational complaint logging with instant UI feedback and automatic scrolling.
* Live Firestore snapshots ensure tickets reflect status changes in real time across faculty, technician, and admin dashboards.

### 4. 📊 Multi-Criteria Filtering & Excel Report Generation
* **Deep Filtering:** Filter complaints by:
  * **Status:** `Pending`, `In Progress`, `Resolved`.
  * **Category:** `Hardware`, `Software`, `Network`, `Exam`, `Access`.
  * **Assigned Technician** and **Lab Location**.
  * **Date Range Picker** with quick range presets.
* **Performance Analytics:** Tracks resolution timestamps and computes exact time taken in minutes.
* **Cross-Platform Excel Export (`.xlsx`):** Formats and downloads clean spreadsheet audits for administrative meetings (native file sharing on Android/iOS; instant file download on Web).

### 5. 🛡️ Role-Based Access Control (RBAC) & Admin Suite
* **Approval Gatekeeping:** New user registrations default to `isApproved = false` until an Administrator approves them.
* **User Management Dashboard:** Search and filter users by role, toggle approvals, edit technician lab assignments, and remove inactive accounts.

---

## 📂 Project Architecture

```text
lib/
├── firebase_options.dart         # FlutterFire platform configuration
├── main.dart                     # App entrypoint & Provider initialization
├── models/
│   ├── lab_model.dart            # Lab entity (dimensions, layout, technician)
│   ├── pc_position_model.dart    # Grid position model
│   └── pc_status_model.dart      # Hardware health checklist & specs
├── providers/
│   ├── auth_provider.dart        # Authentication & current user role state
│   ├── dashboard_provider.dart   # Dashboard counter & metric streams
│   ├── filter_complaint_provider.dart # Multi-criteria filtering logic
│   └── lab_provider.dart         # Labs & PC grid state management
├── routes/
│   └── app_routes.dart           # Named route definitions
├── screens/
│   ├── admin/                    # User management & admin dialogs
│   ├── auth/                     # Login, Signup, Forgot Password
│   ├── chats/                    # Live chat-based reporting interface
│   ├── dashboard/                # Main dashboard, complaint details, filters
│   ├── labs/                     # Lab list, add/edit lab, 2.5D PC grid
│   └── splash_screen.dart        # App launch & auth state router
├── services/
│   ├── auth_service.dart         # Firebase Auth & Firestore user service
│   ├── complains_servcie.dart    # Complaint creation, NLP & routing engine
│   ├── export_excel_service.dart # Spreadsheet report generator
│   └── excel/                    # Platform-specific save helpers (web vs mobile)
├── theme/
│   └── app_theme.dart            # Neon-accented dark theme & styling tokens
├── utils/
│   └── responsive_utils.dart     # Responsive layout breakpoints (Mobile/Web)
└── widgets/
    ├── custom_button.dart
    ├── custom_textfield.dart
    ├── pc_tile_3d.dart           # 2.5D Isometric PC card
    └── animations/
        ├── glass_card.dart       # Glassmorphic card styling
        └── network_background.dart # Canvas node & network animation
```

---

## 🛠️ Getting Started Locally

### Prerequisites
* [Flutter SDK](https://docs.flutter.dev/get-started/install) (`^3.9.2` or later)
* Chrome (for Flutter Web) or Android Studio / Xcode (for mobile development)
* [Firebase CLI](https://firebase.google.com/docs/cli) (optional, for deployments)

### 1. Clone & Install Dependencies
```bash
git clone <repository-url>
cd "Aptech IT Support main"
flutter pub get
```

### 2. Run Locally

**For Web (Chrome):**
```bash
flutter run -d chrome
```

**For Android:**
```bash
flutter run -d android
```

**For Windows Desktop:**
```bash
flutter run -d windows
```

---

## 🚀 Building & Deploying to Firebase

To deploy updates to the live Firebase Hosting environment:

```bash
# 1. Build optimized web bundle
flutter build web --release

# 2. Deploy to Firebase Hosting
firebase deploy --only hosting
```

---

## 📄 License
Internal proprietary software developed for **Aptech Learning Center**. All rights reserved.
