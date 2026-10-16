# ⚛️ Aptech IT Support (React Native / Expo)

> **Enterprise Campus IT Helpdesk & 2.5D Smart Computer Lab Diagnostic System**  
> Re-architected in **React Native (Expo SDK 52 + TypeScript)**, connecting to the live **Google Firebase** backend (`aptech-it-support`).

---

## 🌟 Highlights & Enhancements over Flutter

* **🎨 OLED Dark Mode & Glassmorphism:** Deep slate `#020617` surface with cyan (`#06B6D4`) and electric blue (`#3B82F6`) neon accents, frosted cards, and clean typography.
* **🖥️ True 2.5D Isometric Lab Visualizer:** Hardware monitoring cards transformed in 2.5D space (`transform: [{ rotateX: '-24deg' }, { rotateZ: '-12deg' }]`) with dynamic glowing status borders (Emerald for healthy, Rose for defective).
* **🛠️ Per-PC Diagnostic Modal:** Interactive bottom sheet with switches for Keyboard, Mouse, LED Monitor, VGA/HDMI cables, Power cable, Ethernet LAN, CPU status, and specs (RAM, SSD, OS, technician remarks).
* **💬 Real-Time Chat Ticketing:** Instant ticket creation with NLP keyword categorization (`Hardware`, `Software`, `Network`, `Exam`, `Access`) and regex room extraction (`Lab 101–120`, `201–220`, `JBR Lab`, `IBR Lab`).
* **📊 Multi-Criteria Filter & Excel Export:** Deep ticket searching, filter pills for status/category/date-range, and instant spreadsheet audit generation using SheetJS (`xlsx`).
* **🛡️ Full RBAC & Admin Suite:** Multi-role system (`Admin`, `IT Technician`, `Faculty`) with approval gatekeeping, technician lab routing, and user management.

---

## 📂 Project Structure

```text
Aptech IT Support React/
├── App.tsx                      # Root component & Providers
├── index.ts                     # Expo entrypoint
├── package.json
├── tsconfig.json
├── app.json
└── src/
    ├── config/
    │   └── firebase.ts          # Firebase Modular SDK (Auth + Firestore)
    ├── theme/
    │   ├── colors.ts            # OLED dark tokens & semantic status colors
    │   └── typography.ts        # Hierarchy & typography rules
    ├── types/
    │   ├── user.ts              # UserModel & UserRole
    │   ├── complaint.ts         # ComplaintModel, Statuses, Categories
    │   └── lab.ts               # LabModel, PcStatusModel, isPcHealthy helper
    ├── stores/
    │   ├── useAuthStore.ts      # Reactive auth & profile state
    │   ├── useComplaintStore.ts # Ticket streams, multi-filters
    │   └── useLabStore.ts       # Computer labs & PC workstation state
    ├── services/
    │   ├── authService.ts       # Firebase Auth & User profile management
    │   ├── complaintService.ts  # NLP issue parser, room regex, auto-assignment
    │   └── excelService.ts      # SheetJS (.xlsx) exporter
    ├── navigation/
    │   ├── types.ts             # RootStackParamList typed routes
    │   └── AppNavigator.tsx     # Stack router & themes
    ├── components/
    │   ├── common/
    │   │   ├── CustomButton.tsx
    │   │   ├── CustomInput.tsx
    │   │   ├── GlassCard.tsx
    │   │   └── StatusBadge.tsx
    │   └── labs/
    │       ├── PcTile3D.tsx     # 2.5D Isometric PC card
    │       └── PcStatusModal.tsx# Diagnostic checklist modal
    └── screens/
        ├── auth/
        │   ├── SplashScreen.tsx
        │   ├── LoginScreen.tsx
        │   ├── SignupScreen.tsx
        │   └── ForgotPasswordScreen.tsx
        ├── dashboard/
        │   ├── DashboardScreen.tsx
        │   ├── ComplaintDetailScreen.tsx
        │   └── FilterComplaintsScreen.tsx
        ├── chats/
        │   └── ChatsScreen.tsx
        ├── labs/
        │   ├── LabListScreen.tsx
        │   ├── AddEditLabScreen.tsx
        │   └── Lab3DScreen.tsx
        └── admin/
            ├── ManageUsersScreen.tsx
            └── AdminAddUserScreen.tsx
```

---

## 🚀 Getting Started

### 1. Install Dependencies
```bash
cd "Aptech IT Support React"
npm install
```

### 2. Start Development Server
```bash
# Start Metro bundler (interactive menu)
npx expo start

# Run directly on Web (Chrome browser)
npx expo start --web

# Run on Android emulator / device
npx expo start --android

# Run on iOS simulator
npx expo start --ios
```

---

## 🔒 Security & Environment
All Firebase Auth and Firestore security rules apply. Ensure only authorized credentials are used in testing.

