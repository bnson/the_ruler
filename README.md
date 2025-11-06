# THE RULE.


## 📄 Tài liệu kỹ thuật
- [docs/Log.md](./docs/Log.md): Hướng dẫn cấu hình và sử dụng hệ thống log.
- [docs/NamingConvention.md](./docs/NamingConvention.md): Quy chuẩn đặt tên cho project.
- [docs/SaveSystem.md](./docs/SaveSystem.md): Hướng dẫn lưu và tải game.

## Project Setting
| Setting                       | Properties                    | Value            | Note             |
|-------------------------------|-------------------------------|------------------|------------------|
|`Display - Window - Size`      | Viewport Width                | 480              |                  |
|                               | Viewport Height               | 270              |                  |
|                               | mode                          | True             |                  |
|                               | Resizable                     | True             |                  |
|                               | Aspect                        | expand           |                  |
|`Display - Window - Stretch`   | Mode                          | viewport         |                  |
|                               | Aspect                        | expand           |                  |
|`Input Devices - Pointing`     | Emulate Touch From Mouse      | True             |                  | 
|                               | Emulate Mouse From Touch      | True             |                  |


## 🧩 Phân tích cấu hình Layer tiêu chuẩn cho game RPG (mở rộng)
| Layer | Tên Layer               | Mục đích sử dụng | Ghi chú |
|-------|-------------------------|------------------|--------|
| 1     | `Player`                | Hiển thị nhân vật người chơi | Sprite, animation, Y-sort |
| 2     | `Player Hitbox`         | Vùng tấn công của người chơi | Dùng để gây sát thương lên enemy |
| 3     | `Player Hurtbox`        | Vùng nhận sát thương của người chơi | Enemy đánh trúng sẽ ảnh hưởng |
| 4     | `Enemy`                 | Hiển thị kẻ địch | Sprite, animation |
| 5     | `Enemy Hitbox`          | Vùng tấn công của enemy | Dùng để gây sát thương lên player |
| 6     | `Enemy Hurtbox`         | Vùng nhận sát thương của enemy | Player đánh trúng sẽ ảnh hưởng |
| 7     | `Environment`           | Các thành phần môi trường tĩnh | Tường, nền, cầu thang, vật cản |
| 8     | `Interactable`          | Vật thể có thể tương tác | NPC, rương, cửa, cầu thang chuyển tầng |
| 9     | `Interactable Hitbox`   | Vùng tấn công của vật thể tương tác | Ví dụ: bẫy, turret |
| 10    | `Interactable Hurtbox`  | Vùng nhận sát thương của vật thể tương tác | Ví dụ: rương bị phá, cửa bị đập |
| 11    | `Interactable Detector` | Vùng phát hiện tương tác | Dùng `Area2D` để phát hiện người chơi đến gần |
| 12    | `NPC`                   | Hiển thị nhân vật không điều khiển | Sprite, animation, có thể tương tác |
| 13    | `NPC Detector`          | Vùng phát hiện người chơi | Dùng để kích hoạt hội thoại hoặc hành vi |
| 14    | `Weapon`                | Vũ khí rời hoặc gắn với nhân vật | Có thể có animation riêng |
| 15    | `Skill`                 | Kỹ năng, phép thuật, đạn bay | Gồm projectile, hiệu ứng kỹ năng |
| 16    | `Skill Hitbox`          | Vùng gây sát thương của kỹ năng | Dùng cho phép nổ, tia, đạn |
| 17    | `Skill Hurtbox`         | Vùng nhận sát thương của kỹ năng | Ví dụ: kỹ năng bị phản đòn hoặc hủy |
| 18    | `Effect`                | Hiệu ứng đặc biệt | Ánh sáng, bóng đổ, particle, shader |
| 19    | `UI Detector`           | Vùng phát hiện tương tác UI | Dùng cho menu, bảng chọn, v.v.


## 🧱 Tiêu chuẩn phân lớp TileMapLayer cho game RPG
| Lớp TileMapLayer     | Mục đích sử dụng                         | Ghi chú thêm                              |
|----------------------|------------------------------------------|-------------------------------------------|
| `TileMapGround`      | Nền đất, cỏ, đường đi                    | Lớp thấp nhất, không có collision         |
| `TileMapDetail`      | Chi tiết nền: đá, hoa, vết nứt           | Chồng lên nền, tăng độ sống động          |
| `TileMapWall`        | Tường, hàng rào, vật cản                 | Có thể có collision                       |
| `TileMapObject`      | Cây, thùng, bàn ghế, vật trang trí       | Có thể tương tác hoặc dùng Y-sort         |
| `TileMapRoof`        | Mái nhà, tầng trên                       | Có thể ẩn/hiện tùy camera hoặc trigger    |
| `TileMapOverlay`     | Hiệu ứng ánh sáng, bóng đổ               | Dùng shader hoặc tile bán trong suốt      |
| `TileMapCollision`   | Tile có collision                        | Có thể tách riêng để dễ kiểm soát         |
| `TileMapNavigation`  | Tile dùng cho pathfinding                | Dùng với `NavigationRegion2D`             |

## 🧱 Thư mục & mục đính.
| **Thư mục** | **Mục đích** |
|-------------|--------------|
| `ambience`  | Âm thanh môi trường, tạo không khí cho cảnh game như tiếng gió, mưa, chim hót... Thường phát liên tục và nhẹ nhàng. |
| `bgm`       | Nhạc nền chính của game hoặc từng màn chơi, giúp tạo cảm xúc và tăng sự hấp dẫn cho người chơi. |
| `sfx`       | Hiệu ứng âm thanh phản hồi từ hành động trong game như tiếng nhảy, bắn súng, mở cửa... Thường ngắn và phát khi có sự kiện. |

## 🚀 Một số lệnh check bug
```bash
adb devices
adb install -r The_Rule.apk
adb logcat -c
adb logcat -s godot
adb logcat -c && adb logcat -s godot
---
adb kill-server
adb start-server
adb devices
```

## 🚀 Các lệnh Git thông dụng

```bash
# Thêm toàn bộ file vào staging
git add .

# Tạo commit đầu tiên
git commit -m "Initial commit"

# Đổi tên nhánh hiện tại thành 'main'
git branch -M main

# Đẩy lên repository từ xa
git push https://bnson@github.com/bnson/the_ruler.git

# Kiểm tra các nhánh hiện có
git branch

# Kéo dữ liệu mới nhất từ nhánh 'main' trên GitHub
git pull origin main
