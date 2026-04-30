# 📊 VitaTrack – Cập nhật tiến độ thực tế
> Cập nhật ngày 21/04/2026. Không thay đổi cấu trúc.

---

## ✅ ĐÃ XONG

### Auth
- [x] `features/auth/data/auth_service.dart` — Firebase đăng nhập, đăng ký, đăng xuất, stream
- [x] `features/auth/data/models/user_model.dart` — fromFirebaseUser
- [x] `features/auth/domain/entities/user_entity.dart`
- [x] `features/auth/presentation/providers/auth_provider.dart` — AuthNotifier + authProvider
- [x] `screens/auth/login_screen.dart` — đã kết nối authProvider, dùng ConsumerStatefulWidget, ref.listen hiện SnackBar lỗi, loading state trong nút, KHÔNG tự navigate
- [x] `features/auth/presentation/widgets/auth_wrapper.dart` — ConsumerWidget kiểm tra dangTai / nguoiDung / null, route guard hoàn chỉnh
- [x] `main.dart` — bỏ initialRoute/routes, dùng home: AuthWrapper()
- [x] `features/auth/presentation/providers/onboarding_status_provider.dart` — FutureProvider.autoDispose.family check onboarding status từ Firestore
- [x] `core/services/user_profile_service.dart` — lưu data onboarding lên users/{uid}/profile/info, userProfileServiceProvider
- [x] `screens/onboarding/onboarding_screen.dart` — kết nối userProfileService, invalidate onboardingStatusProvider sau khi lưu
- [x] `features/auth/presentation/widgets/auth_wrapper.dart` — refactor: check onboardingStatusProvider, flow: dangTai → null → onboarding → BottomNav
- [x] `features/auth/data/auth_service.dart` — thêm daHoanThanhOnboarding() + quenMatKhau()
- [x] `features/auth/presentation/providers/auth_provider.dart` — thêm thongBao vào AuthState, quenMatKhau() vào AuthNotifier
- [x] `screens/auth/login_screen.dart` — thêm nút Quên mật khẩu, AlertDialog prefill email, SnackBar xanh khi gửi thành công

### Nutrition
- [x] `features/nutrition/domain/entities/meal_entity.dart`
- [x] `features/nutrition/domain/entities/nutrition.dart`
- [x] `features/nutrition/domain/repositories/nutrition_repository.dart`
- [x] `features/nutrition/domain/usecases/get_daily_nutrition.dart`
- [x] `features/nutrition/data/models/meal_model.dart`
- [x] `features/nutrition/data/datasources/mock_nutrition_datasource.dart`
- [x] `features/nutrition/data/repositories/nutrition_repository_impl.dart`
- [x] `features/nutrition/data/datasources/firestore_nutrition_datasource.dart` — đọc/ghi Firestore theo users/{uid}/nutrition/{date}, tự tạo document mới nếu chưa có, đầy đủ incrementWater/decrementWater/addMeal
- [x] `features/nutrition/presentation/providers/nutrition_provider.dart` — đã refactor: xóa Mock, inject FirestoreNutritionDataSource + uid, load() đọc Firestore thật
- [x] `features/nutrition/presentation/screens/` — nutrition_screen, today_tab, week_tab, add_food_screen...

### Workout
- [x] `features/workout/domain/entities/workout_entity.dart`
- [x] `features/workout/domain/entities/exercise_entity.dart`
- [x] `features/workout/domain/repositories/workout_repository.dart`
- [x] `features/workout/domain/usecases/start_workout.dart`
- [x] `features/workout/domain/usecases/stop_workout.dart`
- [x] `features/workout/domain/usecases/track_workout_progress.dart`
- [x] `features/workout/data/datasources/workout_local_datasource.dart`
- [x] `features/workout/data/repositories/workout_repository_impl.dart`
- [x] `features/workout/presentation/providers/workout_timer_provider.dart`
- [x] `features/workout/presentation/services/workout_timer_service.dart`
- [x] `features/workout/presentation/screens/workout_screen.dart`
- [x] `features/workout/presentation/screens/live_workout_screen.dart`

### Health
- [x] `features/health/domain/entities/health_metric.dart`
- [x] `features/health/data/health_repository.dart` (mock)
- [x] `features/health/presentation/providers/health_provider.dart`

### Core / Services
- [x] `firebase_options.dart`
- [x] `core/theme.dart`, `core/route.dart`, `core/constants.dart`
- [x] `core/services/firestore_service.dart` — base layer Firestore, 6 method generic (set/update/get/getCollection/delete/stream), try/catch đầy đủ, firestoreServiceProvider
- [x] `screens/home/home_screen.dart`
- [x] `screens/ai_coach/` — ai_coach_screen, chat_tab, analysis_tab, plan_tab
- [x] `services/mock_data_service.dart`

---

## ❌ CHƯA XONG

### 🟠 Firestore / Workout
- [ ] `features/workout/domain/entities/activity_entity.dart` — chưa có
- [ ] `features/workout/data/models/activity_model.dart` — chưa có
- [ ] `features/workout/data/datasources/workout_remote_datasource.dart` — chưa có (cần để sync Firestore)

### 🟡 AI Coach thật
- [ ] `features/ai/` — toàn bộ folder chưa tồn tại
- [ ] `features/ai/data/datasources/gemini_datasource.dart` — chưa có
- [ ] `features/ai/presentation/providers/ai_provider.dart` — chưa có
- [ ] `screens/ai_coach/chat_tab.dart` — chưa kết nối provider (đang dùng MockDataService trực tiếp)

---

---

## 📋 VIỆC CẦN LÀM THEO TỪNG NGƯỜI

### 👤 Bạn phụ trách Nutrition
🔴 Việc 1: Tạo tính năng tìm kiếm món ăn
- Tạo food_entity.dart → food_api_datasource.dart → food_search_provider.dart
- API: Open Food Facts (không cần key)
  https://world.openfoodfacts.org/cgi/search.pl?search_terms={query}&json=true&page_size=20

🟡 Việc 2: Gắn vào màn hình add_food_screen.dart
- Ô search → gọi timKiem() → hiện list → chọn món → lưu Firestore

⚠️ Lưu ý: bỏ qua item nếu thiếu calo, inject Dio qua constructor

---

### 👤 Bạn phụ trách Workout
🔴 Việc 1: Tạo tính năng tìm kiếm bài tập
- Tạo activity_entity.dart → workout_remote_datasource.dart → exercise_search_provider.dart
- API: wger (không cần key)
  https://wger.de/api/v2/exercise/?format=json&language=2&term={query}
  Filter cơ bắp: thêm &muscles={id} (1=Biceps 2=Deltoids 3=Abs 4=Chest 5=Triceps 6=Back)

🟡 Việc 2: Gắn vào workout_screen.dart

🟡 Việc 3: Tạo activity_model.dart để lưu lịch sử tập lên Firestore

---

### 👤 Bạn phụ trách Health
🔴 Việc 1: Thay mock bằng sensor thật
- Tạo health_datasource.dart đọc HealthKit/Google Fit
- Sửa health_provider.dart: xóa MockDataService.instance, inject datasource mới

---

### 👤 Bạn phụ trách AI Coach
🔴 Việc 1: Tạo features/ai/ đúng kiến trúc
- Tạo message_entity.dart → gemini_datasource.dart → ai_provider.dart

🟡 Việc 2: Sửa chat_tab.dart
- Xóa MockDataService.instance trong UI
- Thay bằng ref.read(aiProvider.notifier)

---

---

## ⚠️ VI PHẠM CLOT.MD HIỆN TẠI

| File | Vi phạm |
|------|---------|
| `features/health/presentation/providers/health_provider.dart` | Giữ `MockDataService` trong Provider constructor |
| `screens/ai_coach/chat_tab.dart` | `MockDataService.instance` gọi trong UI |

---

# 📅 Cập nhật ngày 30/04/2026 (AI Coach Integration)

## ✅ CÁC PHẦN ĐÃ HOÀN THÀNH (Duy đã fix & chuẩn hóa)
- [x] Chuyển đổi toàn bộ `http` sang `Dio` (Tuân thủ Clot.md).
- [x] Cấu trúc lại folder `features/AI_Coach` theo Clean Architecture (Data/Domain/Presentation).
- [x] Tích hợp `flutter_dotenv` để bảo mật API Key (không để key trong code).
- [x] Fix lỗi duplicate code và các cảnh báo deprecated lints.
- [x] Kích hoạt tab AI Coach trên thanh điều hướng `BottomNav`.

## ❌ CÁC PHẦN BÌNH (AI COACH) CẦN LÀM TIẾP
🔴 **Việc 1: Kết nối dữ liệu sức khỏe thực tế (Integration)**
- Hiện tại `userHealthContextProvider` đang dùng **dữ liệu giả (Mock)**.
- Yêu cầu: Kết nối provider này với `NutritionProvider` (lấy calo, nước thực) và `WorkoutProvider` (lấy số bước, bài tập thực).
- AI phải tư vấn dựa trên dữ liệu người dùng vừa nhập, không được tư vấn số ảo.

🔴 **Việc 2: Chuyển lịch sử Chat lên Firestore (Cloud Sync)**
- Hiện tại `LocalStorageDataSource` đang dùng `shared_preferences` (chỉ lưu trên máy).
- Yêu cầu: Viết `FirestoreAiCoachDataSource` để lưu và tải lịch sử chat từ Firebase Firestore.
- Phải đảm bảo đổi máy vẫn thấy lại lịch sử chat.

🟡 **Việc 3: Hoàn thiện tính năng Giọng nói (Speech-to-Text)**
- Icon Micro trên UI hiện tại chưa có code xử lý.
- Yêu cầu: Tích hợp thư viện nhận diện giọng nói để user có thể nói chuyện với AI.

🟡 **Việc 4: Xử lý giới hạn API và Thông báo chủ động**
- Xử lý lỗi khi hết quota Groq API (Rate limit).
- Nghiên cứu Push Notification để AI Coach chủ động nhắc nhở người dùng khi họ lười tập hoặc thiếu nước.

---

# 📅 Cập nhật ngày 30/04/2026 (Workout & Health Integration)

## 👤 Bạn phụ trách Workout (Hoàng)
🔴 **Việc 1: Xây dựng tính năng Tìm kiếm bài tập (API thực tế)**
- Tạo `exercise_search_provider.dart` để quản lý việc gọi API.
- Kết nối API wger: `https://wger.de/api/v2/exercise/?language=2&format=json`
- Phải có tính năng Search và Filter theo nhóm cơ (Muscles).

🔴 **Việc 2: Giao diện Modern hóa (UI/UX Refactoring)**
- Di chuyển UI từ `lib/screens/activity` sang `lib/features/workout/presentation/screens/`.
- Hiện đại hóa giao diện: dùng Gradient, Glassmorphism và Animation cho các biểu đồ tập luyện.
- Thay thế toàn bộ dữ liệu Mock (static list) bằng dữ liệu thật từ Provider.

🔴 **Việc 3: Kết nối Firestore (Lưu lịch sử tập)**
- Sử dụng `WorkoutRemoteDataSource` đã có.
- Khi người dùng bấm "Lưu" hoặc hoàn thành bài tập, phải đẩy dữ liệu lên Firestore: `users/{uid}/workouts/`.

🔴 **Việc 4: Quản lý trạng thái tập luyện (Live Tracking)**
- Xây dựng `WorkoutTimerProvider` để theo dõi thời gian tập luyện thực tế khi người dùng đang ở màn hình `LiveWorkoutScreen`.
- Đảm bảo khi thoát màn hình hoặc tắt máy (Background), timer vẫn chạy đúng.

🟡 **Việc 5: Tóm tắt kiến thức (Documentation)**
- Viết tài liệu giải thích luồng dữ liệu của phần Workout để chuẩn bị cho buổi bảo vệ đồ án.

## 👤 Bạn phụ trách Health
🔴 **Việc 1: Tích hợp Health Kit (iOS) & Google Fit (Android)**
- Sử dụng thư viện `health` hoặc `pedometer` để lấy số bước chân, nhịp tim THẬT từ cảm biến điện thoại.
- Thay thế toàn bộ số 8245 bước (fake) trong `HealthProvider` bằng dữ liệu thực tế này.
