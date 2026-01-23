class_name SilenceBank
extends RefCounted

# ============== PACKS ==============
# Pack mặc định: thêm câu theo từng mood để tránh lặp.
const DEFAULT_PACK := {
	"tired": [
		{"text": "You stay by quietly, giving them a moment to breathe.", "effects": {"trust": 1}},
		{"text": "You don’t push. A calm silence lingers.", "effects": {"trust": 1}},
		{"text": "You let the quiet do the talking.", "effects": {"trust": 1}}
	],
	"annoyed": [
		{"text": "You give them some space.", "effects": {"trust": 1}},
		{"text": "You wait without adding pressure.", "effects": {"trust": 1}},
		{"text": "You keep your thoughts to yourself.", "effects": {"trust": 1}}
	],
	"busy": [
		{"text": "You stand aside, letting them focus.", "effects": {"trust": 1}},
		{"text": "You keep it short—and silent.", "effects": {"trust": 1}}
	],
	"shy": [
		{"text": "You offer a quiet, reassuring presence.", "effects": {"trust": 1}},
		{"text": "You let the silence feel safe.", "effects": {"trust": 1}}
	],
	"happy": [
		{"text": "You share a quiet smile.", "effects": {}},
		{"text": "You enjoy the moment without words.", "effects": {}}
	],
	"neutral": [
		{"text": "A brief pause. Nothing needed to be said.", "effects": {}},
		{"text": "You simply wait for the right moment.", "effects": {}}
	],
	"any": [
		{"text": "You remain silent for a little while.", "effects": {}}
	]
}

# Pack riêng cho Amice (tuỳ chọn – nếu không cần cứ để rỗng)
const AMICE_GROVER_PACK := {
	"tired": [
		{"text": "You let Amice rest her eyes. She seems grateful.", "effects": {"trust": 1}},
		{"text": "You keep her company quietly—she relaxes a bit.", "effects": {"trust": 1}}
	],
	"any": [
		{"text": "You stay with her without a word.", "effects": {"trust": 1}}
	]
}

# ============== PUBLIC API ==============
static func pick(npc_key: StringName, mood: StringName) -> Dictionary:
	var bank := _merged_for_npc(npc_key)
	var candidates: Array = []

	# gom ứng viên theo mood và "any"
	if bank.has(mood):
		candidates.append_array(bank[mood])
	if bank.has(&"any"):
		candidates.append_array(bank[&"any"])

	if candidates.is_empty():
		return {"text": "You remain silent.", "effects": {}}

	var rng := RandomNumberGenerator.new()
	rng.randomize()
	return candidates[rng.randi_range(0, candidates.size() - 1)]

# ============== INTERNAL ==============
static func _packs() -> Dictionary:
	return {
		&"default": DEFAULT_PACK,
		&"amice_grover": AMICE_GROVER_PACK,
	}

static func _npc_to_pack() -> Dictionary:
	return {
		&"AmiceGrover": &"amice_grover"
	}

static func _merged_for_npc(npc_key: StringName) -> Dictionary:
	var packs := _packs()
	var map := _npc_to_pack()
	var id: StringName = map.get(npc_key, &"default")

	var base: Dictionary = packs.get(&"default", {})
	var spec: Dictionary = packs.get(id, {})

	# merge: append array cho từng mood-key
	var result := {}
	for k in base.keys():
		result[k] = (base[k] as Array).duplicate(true)
	for k in spec.keys():
		if result.has(k):
			result[k].append_array((spec[k] as Array))
		else:
			result[k] = (spec[k] as Array).duplicate(true)
	return result
