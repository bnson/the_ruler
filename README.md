# the_ruler
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
