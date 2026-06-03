# LoveDays — Setup Guide

## Tạo Xcode Project

### Bước 1 — Tạo project mới
1. Mở Xcode → **File > New > Project**
2. Chọn **iOS > App**
3. Điền thông tin:
   - **Product Name:** `LoveDays`
   - **Bundle ID:** `com.yourname.lovedays`
   - **Interface:** SwiftUI
   - **Language:** Swift
   - **Minimum Deployments:** iOS 16.0
4. Lưu project vào thư mục này (cạnh folder `LoveDays/`)

### Bước 2 — Thêm source files
1. Trong Xcode Navigator, **xóa** file `ContentView.swift` mặc định
2. Kéo thả toàn bộ thư mục `LoveDays/` vào Xcode (trừ thư mục `LoveDaysWidget/`)
3. Chọn **"Copy items if needed"** → **"Create groups"**
4. Xóa `LoveDaysApp.swift` mặc định của Xcode (nếu bị trùng)

### Bước 3 — Widget Target
1. **File > New > Target** → tìm **Widget Extension**
2. **Product Name:** `LoveDaysWidget`
3. Bỏ chọn **"Include Configuration App Intent"**
4. Xóa code mặc định trong Widget target
5. Kéo file `LoveDaysWidget/LoveDaysWidget.swift` vào Widget target

### Bước 4 — App Group (để Widget đọc dữ liệu)
1. Main target → **Signing & Capabilities** → **+ Capability** → **App Groups**
2. Thêm group: `group.com.yourname.lovedays`
3. Lặp lại cho Widget target với cùng group ID
4. Trong `LoveDaysWidget.swift`, thay `"group.com.lovedays.app"` thành group ID của bạn
5. Trong `LoveViewModel.swift`, thêm `UserDefaults(suiteName: "group.com.yourname.lovedays")` thay cho `UserDefaults.standard`

### Bước 5 — Permissions (Info.plist)
Thêm các key sau vào `Info.plist`:
```
NSPhotoLibraryUsageDescription = "Để thêm ảnh đôi"
NSUserNotificationsUsageDescription = "Nhắc nhở ngày kỷ niệm"
```

### Bước 6 — Build & Run
- Chọn Simulator hoặc device thật
- **Cmd+R** để build

## Cấu trúc Project

```
LoveDays/
├── LoveDaysApp.swift          ← Entry point (@main)
├── Theme/
│   └── AppTheme.swift         ← Colors, fonts, modifiers
├── Models/
│   └── LoveData.swift         ← DateDifference, Anniversary models
├── ViewModels/
│   └── LoveViewModel.swift    ← State, UserDefaults, timer
├── Utilities/
│   ├── DateCalculator.swift   ← DateComponents calculations
│   ├── HapticManager.swift    ← UIImpactFeedbackGenerator
│   └── NotificationManager.swift ← UNUserNotificationCenter
├── Views/
│   ├── MainView.swift         ← TabView container
│   ├── Onboarding/
│   │   └── OnboardingView.swift  ← 4-page onboarding
│   ├── Home/
│   │   └── HomeView.swift     ← Counter + photo + floating hearts
│   ├── Anniversary/
│   │   └── AnniversaryView.swift ← Countdown + stats
│   └── Settings/
│       └── SettingsView.swift ← Edit names/date/photo/notifs
└── LoveDaysWidget/
    └── LoveDaysWidget.swift   ← WidgetKit (small + medium)
```

## Tính năng đã implement

| Tính năng | File |
|-----------|------|
| Chọn ngày bắt đầu yêu | OnboardingView, SettingsView |
| Số ngày to, nổi bật + animation | HomeView (contentTransition) |
| Chi tiết năm/tháng/ngày/giờ/phút/giây | HomeView |
| Đếm ngược kỷ niệm tháng & năm | AnniversaryView |
| Ảnh đôi có thể thêm/xóa | HomeView, SettingsView |
| Màu hồng pastel + warm white | AppTheme |
| Timer cập nhật mỗi giây | LoveViewModel |
| Floating hearts animation | HomeView |
| Widget màn hình chính (small/medium) | LoveDaysWidget |
| Local Notifications kỷ niệm | NotificationManager |
| Haptic feedback | HapticManager |
| 4-trang onboarding | OnboardingView |
| Dark Mode support | SwiftUI adaptive colors |
| Dynamic Type | .system fonts |
| UserDefaults persistence | LoveViewModel |
