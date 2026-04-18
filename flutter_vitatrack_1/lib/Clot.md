# 🧠 VITATRACK – CLOT.md (AI EXECUTION GUIDE)

---

## 0. 🎯 MỤC TIÊU FILE NÀY

File này dùng để:

* Định nghĩa **cách code duy nhất**
* Đảm bảo **mọi AI code đúng kiến trúc**
* Tránh code sai (API gọi sai chỗ, logic đặt sai layer)

👉 Nếu có conflict: **File này là nguồn sự thật duy nhất (Single Source of Truth)**

---

## 1. 🧭 TỔNG QUAN

VitaTrack là app:

* 🥗 Nutrition tracking
* 💪 Workout / Calisthenics
* ❤️ Health data (Heart rate, steps)
* 🧠 AI Coach

Triết lý:

> Zero → Hero bằng kỷ luật + dữ liệu

---

## 2. 🏗️ KIẾN TRÚC BẮT BUỘC

### 📁 Structure

```
lib/
├── core/
├── features/
│   ├── nutrition/
│   ├── workout/
│   ├── health/
│   └── ai/
```

---

### 📦 Mỗi feature PHẢI có:

```
feature/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
│
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
│
├── presentation/
│   ├── screens/
│   ├── providers/
│   └── widgets/
```

---

## 3. 🔥 DATA FLOW (KHÔNG ĐƯỢC SAI)

```
UI
 ↓
Provider (Riverpod)
 ↓
UseCase
 ↓
Repository (abstract)
 ↓
RepositoryImpl
 ↓
DataSource
 ↓
(API / DB / Sensor)
```

---

## 4. ❌ CÁC ĐIỀU BỊ CẤM

* ❌ Gọi API trong UI
* ❌ Viết logic trong Widget
* ❌ Provider gọi API trực tiếp
* ❌ Bỏ qua UseCase
* ❌ Truy cập HealthKit trực tiếp từ UI

---

## 5. ✅ QUY TẮC THEO TỪNG LAYER

### 🟢 UI (presentation/screens)

Chỉ được:

* render UI
* gọi provider

Không được:

* xử lý logic
* gọi API

---

### 🟡 Provider (Riverpod)

Chỉ:

* giữ state
* gọi usecase

---

### 🔵 UseCase

Chịu trách nhiệm:

* toàn bộ business logic

---

### 🟣 Repository

* định nghĩa contract (domain)
* implement (data)

---

### 🔴 DataSource

👉 NƠI DUY NHẤT được phép:

* gọi API (Dio)
* đọc DB
* đọc HealthKit / Google Fit

---

## 6. 🥗 NUTRITION – CÁCH GỌI API

### Flow chuẩn:

```
NutritionScreen
 → nutritionProvider
 → GetDailyNutrition
 → NutritionRepository
 → NutritionRemoteDataSource
 → API
```

---

### Rule:

> 🔥 API chỉ nằm ở:

```
data/datasources/remote/
```

---

## 7. 💪 WORKOUT – LOGIC

### KHÔNG để trong UI

### Đặt ở:

* UseCase → logic nghiệp vụ
* Service → timer / realtime

---

### Ví dụ:

* timer → service
* reps count → provider
* save workout → usecase

---

## 8. ❤️ HEALTH (HEART RATE)

### Flow:

```
UI
 → Provider
 → GetHeartRate
 → HealthRepository
 → HealthDataSource
 → HealthKit / Google Fit
```

---

### Rule:

> 🔥 Sensor chỉ đọc ở:

```
data/datasources/health/
```

---

## 9. 🧠 AI COACH

### Flow:

```
AI Screen
 → Provider
 → SendMessage UseCase
 → AIRepository
 → AIService (API)
```

---

## 10. 📦 STATE MANAGEMENT

BẮT BUỘC:

* `flutter_riverpod`

---

## 11. 🔌 NETWORK

* Dùng `Dio`
* Không dùng http mặc định

---

## 12. 🧾 NAMING RULE

| Type     | Rule       |
| -------- | ---------- |
| File     | snake_case |
| Class    | PascalCase |
| Variable | camelCase  |

---

## 13. ⚡ PERFORMANCE

* dùng `const` widget
* tránh rebuild
* list → `ListView.builder`

---

## 14. 🧠 CHECKLIST TRƯỚC KHI CODE

AI PHẢI CHECK:

* [ ] Có UseCase chưa?
* [ ] API có nằm ở DataSource không?
* [ ] UI có chứa logic không?
* [ ] Provider chỉ gọi usecase?

👉 Nếu sai 1 cái → phải sửa lại

---

## 15. 🚀 NGUYÊN TẮC CUỐI

> ❗ KHÔNG được code nhanh → code đúng kiến trúc

---

END.
