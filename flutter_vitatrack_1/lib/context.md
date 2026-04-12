# VITATRCK - CONTEXT DỰ ÁN

## Tổng quan
App Flutter theo dõi thể dục & dinh dưỡng
Ngôn ngữ: Dart | Backend: Firebase | AI: Gemini API

## Design System
- Background: #0A0A0F
- Primary: #00E5FF (cyan)
- Secondary: #7C4DFF (tím)  
- Card: #1A1A2E
- Font: Inter | Bo góc: 20px | Dark mode

## Cấu trúc thư mục
lib/
├── core/       → theme.dart ✅ (đã xong)
├── models/     → chưa làm
├── services/   → chưa làm
├── screens/
│   ├── auth/         → login_screen.dart ✅
│   ├── onboarding/   → onboarding_screen.dart ✅
│   ├── home/         → home_screen.dart 🔄 đang làm
│   ├── nutrition/    → chưa làm
│   ├── activity/     → chưa làm
│   ├── ai_coach/     → chưa làm
│   └── profile/      → chưa làm
└── widgets/    → bottom_nav.dart ✅

## Giao diện đã có (mô tả ngắn)
- Login: email + password + nút Google, nền đen
- Onboarding: 4 bước PageView, chấm progress cyan
- Home: card 75% mục tiêu, 4 stat card, AI gợi ý
- Dinh dưỡng: donut chart, 4 chất, cốc nước, bữa ăn
- Hoạt động: bước chân 8234, nhịp tim chart đỏ
- AI Coach: chat bubble, gợi ý câu hỏi nhanh
- Cá nhân: avatar, BMI, mục tiêu, progress bar

## Màn hình đang làm
home_screen.dart - đang làm phần AI gợi ý card

## File quan trọng đã có
theme.dart: [paste nội dung file vào đây]