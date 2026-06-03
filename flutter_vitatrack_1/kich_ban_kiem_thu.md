# 📱 KỊCH BẢN KIỂM THỬ HỆ THỐNG (MANUAL TEST SCRIPT)
> *Dành cho người kiểm thử chạy trực tiếp trên điện thoại. Các bước ngắn gọn, rõ ràng.*

---

## 🔐 Kịch bản 1: Đăng ký, Onboarding & Đăng nhập (Auth)

*   **Bước 1:** Mở ứng dụng. (Giao diện hiển thị màn hình **Đăng nhập**).
*   **Bước 2:** Bấm vào nút **Đăng ký**. 
    *   *Nhập:* Email mới, Mật khẩu (tối thiểu 6 ký tự), Tên hiển thị.
    *   *Kết quả mong đợi:* Đăng ký thành công, chuyển tự động sang màn hình **Onboarding (Khảo sát sức khỏe)**.
*   **Bước 3:** Tại màn hình Onboarding:
    *   *Nhập:* Chọn Mục tiêu (ví dụ: Giảm cân), Nhập chiều cao (cm), Cân nặng (kg), Tuổi, và mức độ vận động. Bấm **Hoàn tất**.
    *   *Kết quả mong đợi:* Dữ liệu lưu lên Firestore thành công, tự động chuyển vào màn hình chính **Dashboard**.
*   **Bước 4:** Test đăng xuất & đăng nhập lại:
    *   Vào tab **Cài đặt** $\rightarrow$ Bấm **Đăng xuất**.
    *   Tại màn hình Đăng nhập: Nhập Email và mật khẩu vừa tạo $\rightarrow$ Bấm **Đăng nhập**.
    *   *Kết quả mong đợi:* Đăng nhập thành công và vào thẳng **Dashboard** (không hiển thị lại màn hình Onboarding vì đã hoàn thành rồi).

---

## 🥘 Kịch bản 2: Quản lý Dinh dưỡng (Nutrition)

*   **Bước 1:** Tại Dashboard, chọn mục **Dinh dưỡng**.
*   **Bước 2:** Cộng nước uống:
    *   Bấm nút **Cộng (+)** tại ô lượng nước uống.
    *   *Kết quả mong đợi:* Số cốc nước tăng lên 1 (cộng thêm 250ml), thanh tiến trình (progress bar) tăng lên tương ứng.
    *   Bấm nút **Trừ (-)** $\rightarrow$ Số cốc nước giảm đi 1.
*   **Bước 3:** Thêm món ăn từ API thực tế:
    *   Bấm nút **Thêm món ăn** (Add Food).
    *   Nhập từ khóa tìm kiếm (Ví dụ: "Sữa", "Bánh mì") vào ô tìm kiếm.
    *   *Kết quả mong đợi:* Danh sách món ăn thật từ API Open Food Facts hiện ra sau khi bạn dừng gõ khoảng 0.5 giây (không bị giật lag).
    *   Chọn một món ăn bất kỳ có hiển thị calo $\rightarrow$ Bấm **Thêm**.
    *   *Kết quả mong đợi:* Quay lại màn hình Dinh dưỡng, tổng calo nạp hôm nay tăng lên, món ăn xuất hiện trong phần Lịch sử ăn uống.

---

## 🏃 Kịch bản 3: Tập luyện & Đếm giờ (Workout)

*   **Bước 1:** Tại Dashboard, chọn mục **Tập luyện**.
*   **Bước 2:** Tìm kiếm bài tập:
    *   Nhập tên bài tập vào ô tìm kiếm (Ví dụ: "Squat", "Push up") hoặc lọc theo Nhóm cơ.
    *   *Kết quả mong đợi:* Danh sách bài tập từ wger API hiển thị.
*   **Bước 3:** Bắt đầu bài tập (Live Workout):
    *   Chọn một bài tập và bấm **Bắt đầu tập**.
    *   *Kết quả mong đợi:* Màn hình đếm ngược (3, 2, 1) xuất hiện, sau đó bộ đếm thời gian tập bắt đầu chạy giây (00:01, 00:02...).
*   **Bước 4:** Thoát app chạy ngầm:
    *   Nhấn Home thoát ra ngoài màn hình chính điện thoại khoảng 5 giây $\rightarrow$ Quay lại app.
    *   *Kết quả mong đợi:* Bộ đếm giờ vẫn tiếp tục chạy đúng thời gian thực tế, không bị đứng hay reset về 0.
*   **Bước 5:** Lưu lịch sử:
    *   Bấm **Hoàn thành bài tập**.
    *   *Kết quả mong đợi:* App thông báo lưu thành công, dữ liệu được ghi lên Firestore, thời gian tập được cộng dồn vào thống kê.

---

## 🩺 Kịch bản 4: Theo dõi số bước chân (Health)

*   **Bước 1:** Bật app và cấp quyền truy cập cảm biến chuyển động (Physical Activity / Motion) khi có pop-up hỏi quyền.
*   **Bước 2:** Cầm điện thoại đi bộ thử vài bước (khoảng 5-10 bước).
*   **Bước 3:** *Kết quả mong đợi:* Số bước chân hiển thị trên màn hình Dashboard tự động nhảy số tăng lên theo nhịp đi của bạn.

---

## 🤖 Kịch bản 5: Trò chuyện & Phân tích bằng AI (AI Coach)

*   **Bước 1:** Vào tab **AI Coach** trên thanh điều hướng.
*   **Bước 2:** Nhận tin nhắn chào mừng:
    *   *Kết quả mong đợi:* Trợ lý AI tự động gửi tin nhắn chào hỏi và hiển thị đúng số bước chân của bạn đã đi hôm nay để làm ngữ cảnh.
*   **Bước 3:** Hỏi AI tư vấn:
    *   Gửi tin nhắn: *"Hôm nay tôi nên ăn gì?"* hoặc *"Lượng calo tôi nạp như vậy đã ổn chưa?"*
    *   *Kết quả mong đợi:* Trợ lý AI phân tích số calo đã nạp (từ Nutrition) và số bước chân/calo tiêu hao (từ Workout) rồi trả về lời khuyên chi tiết, khoa học.
*   **Bước 4:** Chụp ảnh món ăn phân tích (Vision AI):
    *   Bấm vào biểu tượng **Camera/Hình ảnh** $\rightarrow$ Chụp ảnh một món ăn thật trước mặt bạn hoặc chọn ảnh từ máy $\rightarrow$ Gửi đi.
    *   *Kết quả mong đợi:* AI nhận diện được món ăn trong ảnh, tính toán lượng calo ước tính và trả lời về giá trị dinh dưỡng của món đó.
