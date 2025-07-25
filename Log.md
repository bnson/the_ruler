# 📘 Log.md — Quy chuẩn ghi log trong dự án Godot

Tài liệu này mô tả cách hệ thống `Logger.gd` ghi log, định dạng log, và cách đọc file log trong quá trình phát triển và debug.

## ✅ Mục tiêu
Giúp đội ngũ phát triển:
- Dễ dàng theo dõi hành vi runtime.
- Phân tích lỗi nhanh chóng.
- Tối ưu hóa hiệu suất và debug hiệu quả.


## 🧾 Định dạng log

Mỗi dòng log được ghi theo cấu trúc:

```text

[Level][Group][Source] Message

```


### 🔍 Giải thích:

| Thành phần | Ý nghĩa |
|------------|--------|
| `Level`    | Mức độ log: `Debug`, `Warning`, `Error` |
| `Group`    | Nhóm chức năng: `Enemy`, `Player`, `UI`, v.v. |
| `Source`   | Tên node hoặc đối tượng phát sinh log |
| `Message`  | Nội dung log |


### 📌 Ví dụ:

```text
[Debug][Enemy][Slime_01] Initialized with HP: 30
[Warning][Combat][Player] Low HP!
[Error][UI][HUD] Failed to load health bar
```


## 📁 Vị trí file log
- File log được ghi tại: user://debug_log.txt
- Đây là thư mục nội bộ của Godot, có thể truy cập bằng FileAccess.open()
- File sẽ được ghi tiếp mỗi lần chạy nếu WRITE_TO_FILE := true


## ⚠️ Mức độ log

| Mức độ  | Mô tả             | Dùng khi                          |
|--------|-------------------|-----------------------------------|
| Debug  | Thông tin thường nhật | Khởi tạo, trạng thái, dữ liệu     |
| Warning| Cảnh báo           | Giá trị bất thường, gần lỗi       |
| Error  | Lỗi nghiêm trọng   | Không tải được, sai logic         |


## 🧩 Nhóm log
Bạn có thể bật/tắt log theo nhóm bằng cách chỉnh `DEBUG_GROUPS` trong `Logger.gd`.

```gdscript
var DEBUG_GROUPS := {
    "Enemy": true,
    "Player": true,
    "Combat": true,
    "UI": true,
    "Item": true,
    "Skill": true
}
```

## 🛠️ Quy tắc ghi log
- Luôn ghi rõ Group để dễ lọc log
- Dùng get_name() hoặc tên node làm Source
- Tránh ghi log trong vòng lặp mỗi frame (gây tràn file)
- Dùng debug_warn() khi có dấu hiệu bất thường
- Dùng debug_error() khi có lỗi không thể phục hồi




## 📗 Hướng dẫn sử dụng Logger.gd


### 📦 Ghi log


#### 1. Ghi log thông thường

```gdscript

Logger.debug_log(get_name(), "Spawned at position: %s" % global_position, "Enemy")

```

#### 2. Ghi cảnh báo

```gdscript

Logger.debug_warn(get_name(), "HP is below 10", "Player")

```

#### 3. Ghi lỗi

```gdscript

Logger.debug_error("HUD", "Failed to load health bar texture", "UI")

```

### 🔗 Kết nối tín hiệu an toàn

Hàm `connect_signal_once()` giúp:
- kết nối tín hiệu mà không bị trùng lặp.
- Đảm bảo không kết nối nhiều lần.
- Tự động ghi log nếu kết nối thành công.

```gdscript
Logger.connect_signal_once(
    hurtbox,
    "hit_received",
    Callable(self, "_on_hit_received"),
    get_name(),
    "Enemy"
)
```


### 🔧 Bật/tắt nhóm log

Bạn có thể bật/tắt log theo nhóm bằng cách chỉnh `DEBUG_GROUPS`:

```gdscript
Logger.DEBUG_GROUPS["Combat"] = false
Logger.DEBUG_GROUPS["UI"] = true
```

### 🧩 Gợi ý sử dụng theo ngữ cảnh

| Ngữ cảnh           | Gợi ý sử dụng                                 |
|--------------------|-----------------------------------------------|
| Spawn enemy        | `debug_log()` với group `"Enemy"`             |
| Nhân vật bị thương | `debug_warn()` với group `"Player"`           |
| Lỗi UI             | `debug_error()` với group `"UI"`              |
| Kết nối tín hiệu   | `connect_signal_once()` để tránh trùng        |

### 📣 Ghi chú
- Logger nên được thêm vào Autoload để dễ truy cập toàn cục.
- Tránh ghi log quá nhiều trong vòng lặp để không làm chậm game.
- File log có thể dùng để phân tích lỗi sau khi build release.

