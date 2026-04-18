# 📊 VitaTrack – Cập nhật tiến độ thực tế
> Quét code ngày 18/04/2026. Không thay đổi cấu trúc.

---

## ✅ ĐÃ XONG

### Auth
- [x] `features/auth/data/auth_service.dart` — Firebase đăng nhập, đăng ký, đăng xuất, stream
- [x] `features/auth/data/models/user_model.dart` — fromFirebaseUser
- [x] `features/auth/domain/entities/user_entity.dart`
- [x] `features/auth/presentation/providers/auth_provider.dart` — AuthNotifier + authProvider

### Nutrition
- [x] `features/nutrition/domain/entities/meal_entity.dart`
- [x] `features/nutrition/domain/entities/nutrition.dart`
- [x] `features/nutrition/domain/repositories/nutrition_repository.dart`
- [x] `features/nutrition/domain/usecases/get_daily_nutrition.dart`
- [x] `features/nutrition/data/models/meal_model.dart`
- [x] `features/nutrition/data/datasources/mock_nutrition_datasource.dart`
- [x] `features/nutrition/data/repositories/nutrition_repository_impl.dart`
- [x] `features/nutrition/presentation/providers/nutrition_provider.dart`
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

### Core / Setup
- [x] `main.dart` — Firebase.initializeApp + ProviderScope
- [x] `firebase_options.dart`
- [x] `core/theme.dart`, `core/route.dart`, `core/constants.dart`
- [x] `screens/auth/login_screen.dart` — UI đầy đủ
- [x] `screens/home/home_screen.dart`
- [x] `screens/ai_coach/` — ai_coach_screen, chat_tab, analysis_tab, plan_tab
- [x] `services/mock_data_service.dart`

---

## ❌ CHƯA XONG

### 🔴 Auth (bắt buộc để app chạy thật)
- [ ] `screens/auth/login_screen.dart` — chưa kết nối authProvider (navigate hardcode sang OnboardingScreen)
- [ ] `features/auth/presentation/widgets/auth_wrapper.dart` — chưa tồn tại (route guard)
- [ ] `main.dart` — chưa dùng AuthWrapper, đang dùng `initialRoute: /login` cứng

### 🟠 Firestore
- [ ] `core/services/firestore_service.dart` — chưa có
- [ ] `features/workout/domain/entities/activity_entity.dart` — chưa có
- [ ] `features/workout/data/models/activity_model.dart` — chưa có
- [ ] `features/nutrition/data/datasources/firestore_nutrition_datasource.dart` — chưa có (đang dùng mock)

### 🟡 AI Coach thật
- [ ] `features/ai/` — toàn bộ folder chưa tồn tại
- [ ] `features/ai/data/datasources/gemini_datasource.dart` — chưa có
- [ ] `features/ai/presentation/providers/ai_provider.dart` — chưa có
- [ ] `screens/ai_coach/chat_tab.dart` — chưa kết nối provider (đang dùng MockDataService trực tiếp)

---

## ⚠️ VI PHẠM CLOT.MD HIỆN TẠI

| File | Vi phạm |
|------|---------|
| `screens/auth/login_screen.dart` | Import + navigate sang OnboardingScreen trực tiếp trong UI |
| `features/nutrition/presentation/providers/nutrition_provider.dart` | Giữ `_dataSource` field, gọi method mock trực tiếp trong Provider |
| `features/health/presentation/providers/health_provider.dart` | Giữ `MockDataService` trong Provider constructor |
| `screens/ai_coach/chat_tab.dart` | `MockDataService.instance` gọi trong UI |
