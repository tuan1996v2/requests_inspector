<div align="center">
  <img src="https://raw.githubusercontent.com/Abdelazeem777/requests_inspector/main/images/logo_with_text_right.png" height="280">
</div>

# Requests Inspector 🕵️ (Custom Edition)

Phiên bản **Requests Inspector** được custom và tối ưu riêng bởi **tuan1996v2** dành cho các dự án Flutter. Tích hợp sẵn bộ lọc lỗi/thành công, sao chép Token 1-chạm, cURL sharing, xoá nhanh không cần xác nhận và tương thích tuyệt đối với các phiên bản Flutter mới nhất (Flutter 3.16 -> 3.27+).

---

## 🤖 1-Prompt Integration (Dành cho AI ở dự án mới)

> **Mẹo:** Khi bắt đầu một dự án Flutter mới, bạn chỉ cần copy nguyên câu prompt dưới đây và ném vào ô chat cho AI (Cursor, Antigravity, Claude Code, Copilot):

```text
Tích hợp package requests_inspector từ git https://github.com/tuan1996v2/requests_inspector.git vào dự án này: thêm vào pubspec.yaml, bọc ở main.dart, cắm RequestsInspectorInterceptor() vào Dio, sau đó chạy flutter pub get.
```

---

## 📸 Giao Diện Trực Quan

<div align="center">
  <img src="https://raw.githubusercontent.com/Abdelazeem777/requests_inspector/main/images/mobile_list.jpg" width="320" />
  &nbsp;&nbsp;&nbsp;&nbsp;
  <img src="https://raw.githubusercontent.com/Abdelazeem777/requests_inspector/main/images/mobile_request.jpg" width="320" />
</div>

<br/>

<div align="center">
  <img src="https://raw.githubusercontent.com/Abdelazeem777/requests_inspector/main/images/curl_share_request.gif" width="650"/>
  <p><i>Trích xuất lệnh cURL để test lại ngay trên Postman hoặc Terminal 💪</i></p>
</div>

---

## ✨ Tính Năng Nổi Bật (Custom Features)

1. **🔑 Sao chép nhanh Token Authorization (1-Click)**
   - Nút chìa khoá Amber trên AppBar và menu popup.
   - Thẻ riêng trong trang chi tiết request.
   - Tự động quét headers tìm `Authorization` và cắt bỏ tiền tố `Bearer `, chỉ copy chuỗi token thô để gửi BE xin quyền/test API.

2. **🎯 Bộ lọc thông minh & Tìm kiếm endpoint**
   - Lọc nhanh theo trạng thái: **Tất cả**, **🔴 Lỗi (Status >= 400)**, **🟢 Thành công (200 - 299)**.
   - Thanh tìm kiếm mượt mà hỗ trợ tìm theo URL, endpoint name hoặc HTTP method.

3. **⚡ Bấm đúp để xoá nhanh (Double-Tap Quick Clear)**
   - Bấm 1 lần: Hiện hộp thoại xác nhận.
   - Bấm 2 lần liên tiếp: Xoá sạch toàn bộ log ngay lập tức mà không cần xác nhận.

4. **📋 Xuất lệnh cURL & Chia sẻ linh hoạt**
   - Chuyển đổi mọi HTTP request thành lệnh `cURL` chuẩn để ném sang Postman hoặc Terminal.
   - Hỗ trợ chia sẻ: chỉ cURL, chỉ Log chi tiết, hoặc cả hai.

5. **🌳 JSON Tree View & Dark Mode**
   - Hỗ trợ xem JSON dạng phẳng hoặc dạng cây thu gọn/mở rộng từng node.
   - Hỗ trợ Dark Mode / Light Mode tuỳ biến.

6. **🛡️ Tương thích hoàn toàn với Flutter mới**
   - Đã nâng cấp `PopScope` chuẩn (thay thế `WillPopScope` bị deprecated).
   - Dải dependencies mở rộng (`dio: >=5.0.0 <6.0.0`, `provider`, `sensors_plus`, `share_plus`), không gây xung đột dependency tree với bất kỳ dự án nào.

---

## 🚀 Cài Đặt Thủ Công

### 1. Thêm vào `pubspec.yaml`
```yaml
dependencies:
  requests_inspector:
    git:
      url: https://github.com/tuan1996v2/requests_inspector.git
      ref: main
```

Sau đó chạy lệnh:
```bash
flutter pub get
```

### 2. Bọc `RequestsInspector` ở Root App (`main.dart`)
```dart
import 'package:flutter/foundation.dart';
import 'package:requests_inspector/requests_inspector.dart';

void main() {
  runApp(
    RequestsInspector(
      enabled: kDebugMode, // Chỉ kích hoạt khi chạy Debug/Dev
      child: const MyApp(),
    ),
  );
}
```

### 3. Cắm Interceptor vào `Dio`
```dart
import 'package:requests_inspector/requests_inspector.dart';

final dio = Dio();
dio.interceptors.add(RequestsInspectorInterceptor());
```

---

## 📱 Cách Mở Bảng Inspector

- **Lắc điện thoại (Shake):** Mặc định khi lắc thiết bị trên Android/iOS, bảng Inspector sẽ tự popup.
- **Bằng code / Nút bấm ẩn:** Gọi ở bất kỳ sự kiện nào trong app:
  ```dart
  InspectorController().showInspector();
  ```
- **Ghi log thủ công (dành cho tải file hoặc client khác):**
  ```dart
  InspectorController().addNewRequest(
    RequestDetails(
      requestMethod: RequestMethod.GET,
      url: 'https://api.example.com/data',
      statusCode: 200,
      headers: {'Authorization': 'Bearer ...'},
      responseBody: 'Response content',
    ),
  );
  ```

---

## 📃 License
MIT License - Tự do sử dụng cho mọi dự án cá nhân và thương mại.
