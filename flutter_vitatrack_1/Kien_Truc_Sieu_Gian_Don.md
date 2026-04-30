# 🆘 PHAO CỨU SINH: GIẢI THÍCH KIẾN TRÚC VITATRACK

> Dành cho nhóm trưởng để đối phó với các câu hỏi "xoáy" của thầy về cấu trúc code.

---

## 1. 🥘 ẨN DỤ "NHÀ HÀNG" (Dễ hiểu nhất)
Để giải thích Clean Architecture, bạn hãy tưởng tượng app là một nhà hàng:

*   **Presentation (UI + Provider):** Là **Bồi bàn**. Người này đứng ở sảnh (Screen), nhận order từ khách, rồi mang vào bếp. Bồi bàn không biết nấu ăn, chỉ biết chuyển lời.
*   **Domain (UseCase + Entity):** Là **Bếp trưởng**. Người này giữ "Công thức nấu ăn" (Logic nghiệp vụ). Bếp trưởng quyết định món này nấu thế nào, cần nguyên liệu gì, nhưng không trực tiếp đi chợ.
*   **Data (DataSource + Repository):** Là **Người đi chợ**. Người này ra chợ (API/Firebase) để lấy nguyên liệu về cho bếp. Bếp trưởng bảo cần "Thịt bò", người đi chợ lấy ở đâu (Siêu thị hay Chợ đầu mối) thì Bếp trưởng không cần quan tâm.

---

## 2. 🧠 GIẢI THÍCH THUẬT NGỮ (Dân dã)

### 📻 Riverpod & Provider là gì?
*   **Riverpod:** Là cái **Tổng đài điện thoại** của cả app.
*   **Provider:** Là một **Kênh chuyên biệt**. Ví dụ `authProvider` là kênh chuyên về Đăng nhập.
*   **ref.watch() / ref.read():** Là hành động **"Nhấc máy nghe"**. Khi bạn dùng `ref.watch`, hễ kênh đó có thông tin mới là cái Screen của bạn tự động cập nhật theo (rebuild).

### 📝 UseCase là gì?
*   Là **"Một hành động cụ thể"**. 
*   Ví dụ: `GetDailyNutrition` chỉ làm đúng 1 việc là lấy dữ liệu dinh dưỡng. Nếu thầy hỏi *"Tại sao không gộp hết vào 1 file?"* -> Trả lời: *"Dạ để code **Single Responsibility (Đơn nhiệm)**, sau này sửa chức năng này không làm hỏng chức năng kia."*

---

## 3. 🗺️ LUỒNG ĐI CỦA CODE (Code Flow)
Khi thầy bảo: *"Em thử giải thích code chạy thế nào khi ấn nút Đăng nhập?"*

1.  **UI:** `login_screen.dart` gọi hàm đăng nhập của `authProvider`.
2.  **Provider:** `authProvider` nhấc máy gọi thằng **UseCase** (ví dụ: `LoginUseCase`).
3.  **UseCase:** Thằng này kiểm tra logic (email có @ không...), sau đó gọi thằng **Repository**.
4.  **Repository:** Thằng này nói với **DataSource**: *"Lấy dữ liệu từ Firebase cho tao"*.
5.  **DataSource:** Đây là nơi duy nhất dùng thư viện Firebase để thực sự kết nối Internet.
6.  **Trả về:** Dữ liệu đi ngược lại từ DataSource -> Repository -> UseCase -> Provider -> UI hiện lên chữ "Thành công".

---

## 4. ⚡ CÁC CÂU HỎI "TỬ THẦN" CỦA THẦY

**Câu 1: "Tại sao em chia folder phức tạp vậy, viết chung một file có chạy được không?"**
*   **Trả lời:** Dạ chạy được, nhưng app sẽ trở thành "Spaghetti code" (rối như tơ vò). Chia thế này để **Dễ bảo trì** và **Dễ kiểm thử (Testing)**. Nếu sau này mình muốn thay Firebase bằng một Database khác, mình chỉ cần sửa ở lớp **Data**, lớp **UI** và **Logic** hoàn toàn không phải đụng vào.

**Câu 2: "Entity và Model khác nhau chỗ nào?"**
*   **Trả lời:** 
    *   **Entity:** Là dữ liệu "sạch", chỉ chứa những gì app cần hiển thị (ví dụ: Tên, Tuổi).
    *   **Model:** Là dữ liệu "thô" đi kèm với các hàm chuyển đổi như `fromJson`, `toMap` để làm việc với Database. Model nằm ở lớp Data, còn Entity nằm ở lớp Domain.

**Câu 3: "Riverpod có ưu điểm gì so với Provider cũ hay setState?"**
*   **Trả lời:** Dạ Riverpod giúp quản lý State một cách **Compile-safe** (bắt lỗi ngay khi code) và không bị phụ thuộc vào BuildContext, giúp mình có thể lấy dữ liệu ở bất cứ đâu trong app mà không sợ bị lỗi "Provider not found".

---

## 💡 LỜI KHUYÊN CUỐI
Bạn không cần hiểu 100% code viết gì bên trong. Bạn chỉ cần hiểu **"Cái file đó nằm ở đó để làm nhiệm vụ gì"**. Thầy chấm điểm đồ án thường chấm tư duy kiến trúc của bạn nhiều hơn là soi từng dấu chấm dấu phẩy trong code.

**Tự tin lên, bạn đang dùng kiến trúc của những kỹ sư Senior đấy!**
