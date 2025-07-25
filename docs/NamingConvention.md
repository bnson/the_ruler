# 📘 Quy Chuẩn Đặt Tên Cho Project Game RPG (Godot 4)

Quy chuẩn này giúp đảm bảo tính nhất quán, dễ mở rộng, dễ bảo trì và dễ làm việc nhóm trong quá trình phát triển game RPG bằng Godot.

---

## 1. 🧪 Bảng Kiểm Tra Nhanh

| Loại        | Kiểu viết     | ✅ Ví dụ đúng           | ❌ Ví dụ sai              |
|-------------|----------------|--------------------------|---------------------------|
| Folder      | `snake_case`   | `enemy/`                 | `Enemy/`                  |
| Scene       | `PascalCase`   | `Level01Main.tscn`       | `level_01_main.tscn`      |
| Script      | `PascalCase`   | `PlayerController.gd`    | `player_controller.gd`    |
| Asset       | `snake_case`   | `goblin_attack.png`      | `GoblinAttack.png`        |
| Viết tắt    | `PascalCase`   | `NpcMerchant.gd`         | `NPCMerchant.gd`          |


## 2. 📁 Thư Mục (Folder)

- **Kiểu viết**: `snake_case`
- **Lý do**: Dễ gõ, tránh lỗi case-sensitive trên Linux/Android
- **Ví dụ**:
  - `levels/`, `player/`, `enemy/`, `ui/`, `systems/`, `managers/`, `assets/`

---

## 2. 📄 Scene (.tscn) & Script (.gd)

- **Kiểu viết**: `PascalCase`
- **Tên file = Tên class** (nếu có)
- **Không dùng dấu gạch dưới `_`**
- **Từ viết tắt**: Viết hoa chữ cái đầu, không toàn bộ (`Npc`, không phải `NPC`)
- **Ví dụ**:
  - `Level01Main.tscn`, `Level01Main.gd`
  - `PlayerController.gd`, `EnemyGoblin.tscn`
  - `InventoryUi.tscn`, `QuestSystem.gd`
  - `NpcMerchant.tscn`, `DialogueManager.gd`

---

## 3. 🖼️ Asset (Ảnh, Âm thanh, Font, Animation...)

- **Kiểu viết**: `snake_case`
- **Tên mô tả rõ chức năng**
- **Không viết hoa**
- **Ví dụ**:
  - `player_idle.png`, `goblin_attack.png`
  - `bg_music_loop.ogg`, `sword_swing.wav`
  - `main_font.tres`, `inventory_open.anim`

---

## 4. 🧠 Autoload (Singleton)

- **Kiểu viết**: `PascalCase`
- **Tên mô tả rõ vai trò**
- **Ví dụ**:
  - `GameManager.gd`, `AudioManager.gd`, `SaveManager.gd`, `DialogueManager.gd`

---

## 5. 🧩 Từ Viết Tắt (ID, UI, NPC, HP...)

- **Quy tắc**: Viết hoa chữ cái đầu, không toàn bộ
- **Ví dụ**:
  - `NpcVillager.tscn`, `UiInventory.gd`, `HpBar.gd`, `ItemIdGenerator.gd`

---

## 6. 📦 Tổ Chức Thư Mục Theo Module

```plaintext
src/
├── levels/
│   ├── level01/
│   │   ├── Level01Main.tscn
│   │   ├── Level01Main.gd
│   │   ├── Level01BossRoom.tscn
│   │   └── Level01Cutscene.tscn
├── player/
│   ├── Player.tscn
│   └── PlayerController.gd
├── enemy/
│   ├── EnemyGoblin.tscn
│   └── EnemyBoss.tscn
├── ui/
│   ├── InventoryUi.tscn
│   └── MainMenu.tscn
├── systems/
│   ├── CombatSystem.gd
│   ├── InventorySystem.gd
│   └── QuestSystem.gd
├── managers/
│   ├── GameManager.gd
│   ├── AudioManager.gd
│   └── SaveManager.gd
