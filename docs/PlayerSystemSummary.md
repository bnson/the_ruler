
# ✅ Tóm tắt hệ thống Player đã cải thiện

## 1. `Player.gd`
- Kế thừa `CharacterBody2D`, điều khiển di chuyển bằng joystick.
- Sử dụng `signal` để giao tiếp với UI và các hệ thống khác.
- Có thuộc tính `player_state` chứa thông tin stats, inventory,...
- Phát các `signal` như: `damaged`, `healed`, `level_up`,...

---

## 2. `PlayerState.gd`
- Là một `Resource`, chứa:
  - `Stats`: máu, mana, level,...
  - `Inventory`: danh sách item
- Dùng `signal` nội bộ để báo thay đổi dữ liệu.
- Được quản lý bởi `GameState` (Autoload).

---

## 3. `GameState.gd`
- Là một `Autoload` chứa:
  ```gdscript
  var player: PlayerState
  ```
- Kết nối `player.stats` và `player.inventory` đến các `signal` toàn cục:
  - `stats_changed`
  - `inventory_changed`

---

## 4. `Global.gd`
- Cũng là một `Autoload`.
- Quản lý:
  ```gdscript
  var player: Player = null
  var player_scene: PackedScene
  ```
- Các hàm chính:
  - `ensure_player_exists()`
  - `detach_player()`
  - `attach_player_to(container: Node, spawn_position: Vector2)`

---

## 5. `PlayerSpawn.tscn`
- Là một node đánh dấu vị trí xuất hiện của Player trong scene.

---

## 6. `Level01Main.gd`
- Trong `_ready()` gọi:
  ```gdscript
  Global.attach_player_to($SceneContainer, $PlayerSpawn.global_position)
  ```
- Tránh lỗi `add_child()` bằng `call_deferred()` hoặc kiểm tra parent trước.

---

## 7. `PlayerUi.gd`
- Giao tiếp với `Player` hoặc `GameState` thông qua `signal`.
- Hiển thị các chỉ số: máu, năng lượng, level,...
- Đã refactor để chỉ cập nhật khi có sự thay đổi thực sự.

---

## 📌 Phong cách thiết kế:
- Ưu tiên `Autoload` cho trạng thái (`GameState`), **không Autoload node.**
- Truy cập `Player` node thông qua `Global.gd`.
- Dùng `signal` để **giữ liên kết lỏng**, không hard-code đường dẫn.
