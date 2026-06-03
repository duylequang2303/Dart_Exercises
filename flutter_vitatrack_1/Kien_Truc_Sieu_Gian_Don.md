# 🆘 PHAO CỨU SINH: GIẢI THÍCH KIẾN TRÚC VITATRACK (MỚI NHẤT)

> Dành cho nhóm bảo vệ đồ án đối phó với các câu hỏi "xoáy" của thầy cô về cấu trúc code, công nghệ và luồng xử lý.

---

## 1. 🥘 ẨN DỤ "NHÀ HÀNG" (Cách giải thích Clean Architecture dễ hiểu nhất)

Để giải thích Clean Architecture, bạn hãy tưởng tượng app là một nhà hàng:

*   **Presentation (UI + Provider):** Là **Bồi bàn**. Người này đứng ở sảnh (Screen), nhận order từ khách, rồi mang vào bếp. Bồi bàn không biết nấu ăn, chỉ biết chuyển lời.
*   **Domain (UseCase + Entity):** Là **Bếp trưởng**. Người này giữ "Công thức nấu ăn" (Logic nghiệp vụ của dự án). Bếp trưởng quyết định món này nấu thế nào, cần nguyên liệu gì, nhưng không trực tiếp đi chợ.
*   **Data (DataSource + Repository):** Là **Người đi chợ**. Người này ra chợ (API/Firebase/Local Database) để lấy nguyên liệu về cho bếp. Bếp trưởng bảo cần "Thịt bò", người đi chợ lấy ở đâu (Siêu thị hay Chợ đầu mối) thì Bếp trưởng không cần quan tâm.

---

## 2. 🗺️ CẤU TRÚC THƯ MỤC CÁC TÍNH NĂNG (Features Structure)

Dự án được chia theo các module tính năng (**Feature-Driven**) dưới thư mục `lib/features/`:

### 🔐 1. Auth (Xác thực người dùng)
*   **Data:** `auth_service.dart` kết nối trực tiếp với Firebase Authentication để xử lý đăng ký, đăng nhập và quên mật khẩu.
*   **Presentation:** `auth_provider.dart` (quản lý trạng thái đăng nhập) và `auth_wrapper.dart` (tự động chuyển hướng giữa màn hình Login, Onboarding và Dashboard chính dựa trên trạng thái người dùng).

### 🥘 2. Nutrition (Dinh dưỡng)
*   **API & Database:** Kết nối với **Open Food Facts API** qua thư viện `Dio` để tìm kiếm sản phẩm dinh dưỡng thực phẩm thực tế.
*   **UX Tối ưu:** Có cơ chế **Debounce (500ms)** trong `food_search_provider.dart` để tránh gửi hàng trăm request spam API khi người dùng đang gõ phím.
*   **Cloud Sync:** Đồng bộ lịch sử dinh dưỡng hàng ngày lên Firebase Firestore theo cấu trúc `users/{uid}/nutrition/{date}`.

### 🏃 3. Workout (Tập luyện)
*   **API:** Tìm kiếm bài tập thể hình qua **wger API** theo từ khóa và lọc theo nhóm cơ (Muscles).
*   **Live Tracking:** Sử dụng `WorkoutTimerService` để quản lý bộ đếm giờ (thời gian trôi qua và đếm ngược) hoạt động chính xác cả khi thoát màn hình hoặc chạy ngầm.
*   **Cloud Sync:** Tự động đồng bộ và lưu lịch sử bài tập của người dùng lên Firestore `users/{uid}/workouts/`.

### 🩺 4. Health (Sức khỏe)
*   **Cảm biến thực tế:** Tích hợp thư viện `pedometer` để đọc dữ liệu số bước chân trực tiếp từ cảm biến phần cứng của điện thoại (yêu cầu cấp quyền `ACTIVITY_RECOGNITION` trên Android và `NSMotionUsageDescription` trên iOS).
*   **Sync:** Đưa số bước chân thật vào biểu đồ để AI phân tích.

### 🤖 5. AI Coach (Trợ lý AI)
*   **Groq Vision AI:** Tích hợp camera điện thoại để chụp ảnh món ăn/thành phần dinh dưỡng, gửi ảnh trực tiếp qua API Groq để phân tích calo và đưa ra lời khuyên.
*   **Context-Aware:** AI không khuyên "ảo", mà đọc trực tiếp dữ liệu sức khỏe thật của ngày hôm đó (calo nạp vào từ Nutrition, calo tiêu hao và số bước chân từ Workout/Health) để đưa ra lời khuyên cá nhân hóa chính xác nhất.

---

## 3. ⚡ CÁC CÂU HỎI "TỬ THẦN" CỦA THẦY CÔ & CÁCH TRẢ LỜI

### 💬 Câu 1: "Tại sao em chia folder phức tạp vậy, viết chung một file có chạy được không?"
*   **Trả lời:** *"Dạ chạy được, nhưng app sẽ trở thành Spaghetti code (rối như tơ vò) khi dự án lớn lên. Nhóm em chia theo kiến trúc Clean Architecture để **Dễ bảo trì** và **Dễ kiểm thử (Testing)**. Nếu sau này nhóm muốn đổi từ Firebase sang MySQL, nhóm chỉ cần sửa lớp **Data**, còn lớp **UI** và **Domain (Logic)** hoàn toàn giữ nguyên, không cần viết lại."*

### 💬 Câu 2: "Entity và Model khác nhau chỗ nào?"
*   **Trả lời:** 
    *   **Entity:** Là dữ liệu "sạch" chỉ chứa thông tin logic cốt lõi mà UI cần hiển thị (ví dụ: `UserEntity` chứa tên, email). Nó thuộc lớp Domain.
    *   **Model:** Là lớp mở rộng của Entity chứa các hàm bổ trợ như `fromJson()`, `toJson()` hoặc `toMap()` để chuyển đổi dữ liệu thô từ API/Database. Nó thuộc lớp Data.

### 💬 Câu 3: "Riverpod có ưu điểm gì so với Provider cũ hay setState?"
*   **Trả lời:** *"Dạ Riverpod giúp quản lý State một cách **Compile-safe** (báo lỗi ngay lúc viết code thay vì lúc chạy app) và loại bỏ sự phụ thuộc vào `BuildContext`. Điều này giúp nhóm dễ dàng gọi và chia sẻ trạng thái ở bất kỳ đâu trong dự án, đồng thời hỗ trợ viết Test Case cực kỳ độc lập mà không cần giả lập cây Widget."*

### 💬 Câu 4: "Ứng dụng này kiểm thử (Test) như thế nào?"
*   **Trả lời:** *"Dạ dự án có tích hợp bộ kiểm thử tự động (Automated Testing) nằm trong thư mục `test/`. Bọn em viết các Unit Test kiểm thử logic tính toán calo của Nutrition, đếm giây của Workout Timer, và định dạng tin nhắn của AI. Nhóm chạy lệnh `flutter test` để hệ thống tự động xác nhận toàn bộ logic mà không cần bấm thủ công trên điện thoại."*
