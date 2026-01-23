class_name AskBank
extends RefCounted

#===================================================================
const DEFAULT_PACK = [
	# ===================== HAPPY =====================
	{
		"id": "ask_happy_1",
		"text": "You look cheerful today. Something good happened?",
		"expected_moods": ["happy"],
		"correct_effects": {"love": 1, "trust": 1},
		"wrong_effects": {"love": -1},
		"npc_responses_correct": [
			"Yeah! Today has been really good!",
			"Totally! Something great happened!",
			"I'm in a great mood, thanks for noticing!"
		],
		"npc_responses_wrong": [
			"Oh... I'm not that cheerful actually.",
			"Not really… but thanks I guess.",
			"I don't feel that happy today."
		]
	},

	{
		"id": "ask_happy_2",
		"text": "You seem to be in a great mood!",
		"expected_moods": ["happy"],
		"correct_effects": {"trust": 1},
		"wrong_effects": {"love": -1},
		"npc_responses_correct": [
			"I really am! It feels like a lucky day.",
			"Yep! Everything's been going well.",
			"I'm feeling great, thanks for noticing!"
		],
		"npc_responses_wrong": [
			"I’m not in that great of a mood, honestly.",
			"I don’t feel that cheerful.",
			"Not exactly… but nice guess."
		]
	},

	{
		"id": "ask_happy_3",
		"text": "You're glowing today! Feeling good?",
		"expected_moods": ["happy"],
		"correct_effects": {"love": 2},
		"wrong_effects": {"trust": -1},
		"npc_responses_correct": [
			"Haha, thanks! I'm feeling amazing.",
			"Yep! I’m full of energy today.",
			"Absolutely! It's a wonderful day."
		],
		"npc_responses_wrong": [
			"Glowing? I don’t think so.",
			"Not really… I’m not feeling that good.",
			"I don’t feel energetic today."
		]
	},

	{
		"id": "ask_happy_4",
		"text": "Looks like you're having a wonderful day.",
		"expected_moods": ["happy"],
		"correct_effects": {"trust": 1, "love": 1},
		"wrong_effects": {"love": -1},
		"npc_responses_correct": [
			"I really am, thanks!",
			"Yep! It’s been a surprisingly nice day.",
			"Yeah! Today feels really positive."
		],
		"npc_responses_wrong": [
			"Not exactly a wonderful day…",
			"I don’t feel that positive.",
			"It’s actually been a bit rough."
		]
	},

	# ===================== NEUTRAL =====================
	{
		"id": "ask_neutral_1",
		"text": "You seem calm today. Everything alright?",
		"expected_moods": ["neutral"],
		"correct_effects": {"trust": 1},
		"wrong_effects": {"love": -1},
		"npc_responses_correct": [
			"Yeah, everything’s fine.",
			"It’s just a normal day.",
			"Yep, nothing special going on."
		],
		"npc_responses_wrong": [
			"Calm? Not exactly.",
			"I’m not feeling neutral right now.",
			"That's not really my mood."
		]
	},

	{
		"id": "ask_neutral_2",
		"text": "You look pretty relaxed. How’s your day going?",
		"expected_moods": ["neutral"],
		"correct_effects": {"trust": 1},
		"wrong_effects": {"trust": -1},
		"npc_responses_correct": [
			"It’s been okay so far.",
			"Just a pretty average day.",
			"I’m doing fine, thanks."
		],
		"npc_responses_wrong": [
			"I’m not really relaxed.",
			"Not really… my day’s been strange.",
			"Relaxed isn’t the right word."
		]
	},

	{
		"id": "ask_neutral_3",
		"text": "You feel kind of neutral today. Thinking about something?",
		"expected_moods": ["neutral"],
		"correct_effects": {"trust": 1},
		"wrong_effects": {"love": -1},
		"npc_responses_correct": [
			"Yeah, just thinking a bit.",
			"Nothing too important on my mind.",
			"I’m just normal today."
		],
		"npc_responses_wrong": [
			"Neutral? Not how I feel.",
			"I don’t feel that calm.",
			"My mood isn’t neutral right now."
		]
	},

	# ===================== TIRED =====================
	{
		"id": "ask_tired_1",
		"text": "You look tired today. Did you sleep well?",
		"expected_moods": ["tired"],
		"correct_effects": {"trust": 1},
		"wrong_effects": {"love": -1},
		"npc_responses_correct": [
			"No… I didn’t sleep well.",
			"Yeah… I’m really exhausted.",
			"I’m feeling worn out."
		],
		"npc_responses_wrong": [
			"Tired? Not really.",
			"I don’t feel sleepy.",
			"I’m not that tired today."
		]
	},

	{
		"id": "ask_tired_2",
		"text": "You seem exhausted. Want to talk about it?",
		"expected_moods": ["tired"],
		"correct_effects": {"love": 1, "trust": 1},
		"wrong_effects": {"trust": -1},
		"npc_responses_correct": [
			"I could use someone to talk to…",
			"Yeah… today’s been rough.",
			"I’m just really drained."
		],
		"npc_responses_wrong": [
			"Exhausted? Not really.",
			"I’m fine, just normal.",
			"I’m not that drained."
		]
	},

	{
		"id": "ask_tired_3",
		"text": "You look worn out… Are you okay?",
		"expected_moods": ["tired"],
		"correct_effects": {"trust": 1},
		"wrong_effects": {"love": -1},
		"npc_responses_correct": [
			"I’m okay… just tired.",
			"I need some rest, that’s all.",
			"Yeah… I’m just worn out."
		],
		"npc_responses_wrong": [
			"I don’t feel worn out.",
			"I’m fine, really.",
			"You’re overthinking it."
		]
	},

	{
		"id": "ask_tired_4",
		"text": "You seem like you need a break.",
		"expected_moods": ["tired"],
		"correct_effects": {"trust": 2},
		"wrong_effects": {"love": -1},
		"npc_responses_correct": [
			"I do… thanks for noticing.",
			"I could really use one.",
			"Yeah… I need a moment."
		],
		"npc_responses_wrong": [
			"I don’t really need a break.",
			"I’m not tired enough for that.",
			"I’m okay, really."
		]
	},

	# ===================== BUSY =====================
	{
		"id": "ask_busy_1",
		"text": "You seem busy today. Need any help?",
		"expected_moods": ["busy"],
		"correct_effects": {"trust": 1},
		"wrong_effects": {"love": -1},
		"npc_responses_correct": [
			"I am! Actually, help would be nice.",
			"Yeah… I’ve got a lot to handle.",
			"I’m super busy today."
		],
		"npc_responses_wrong": [
			"Nope, not busy at all.",
			"I’m not doing much.",
			"Busy? Not really."
		]
	},

	{
		"id": "ask_busy_2",
		"text": "Looks like you’ve got a lot going on.",
		"expected_moods": ["busy"],
		"correct_effects": {"trust": 1},
		"wrong_effects": {"trust": -1},
		"npc_responses_correct": [
			"I do… it’s a hectic day.",
			"Yeah, everything’s piling up.",
			"It’s been non-stop."
		],
		"npc_responses_wrong": [
			"A lot? Not really.",
			"I’m pretty free.",
			"I’m not overloaded today."
		]
	},

	{
		"id": "ask_busy_3",
		"text": "You look focused. Lots of work today?",
		"expected_moods": ["busy"],
		"correct_effects": {"trust": 1},
		"wrong_effects": {"love": -1},
		"npc_responses_correct": [
			"Yeah, so much to do.",
			"It’s been a super productive day.",
			"I’m trying to stay focused."
		],
		"npc_responses_wrong": [
			"Focused? Not really.",
			"I’m not working much today.",
			"That’s not the case."
		]
	},

	# ===================== SHY =====================
	{
		"id": "ask_shy_1",
		"text": "You look a bit shy today. Did something happen?",
		"expected_moods": ["shy"],
		"correct_effects": {"love": 1},
		"wrong_effects": {"trust": -1},
		"npc_responses_correct": [
			"Y-Yeah… I’m just a bit shy.",
			"I’m feeling nervous today.",
			"You noticed… I’m a little flustered."
		],
		"npc_responses_wrong": [
			"Shy? No… not really.",
			"I’m not flustered.",
			"Nothing like that."
		]
	},

	{
		"id": "ask_shy_2",
		"text": "You seem quiet… everything okay?",
		"expected_moods": ["shy"],
		"correct_effects": {"trust": 1},
		"wrong_effects": {"love": -1},
		"npc_responses_correct": [
			"I’m okay… just quiet today.",
			"I’m feeling a bit timid.",
			"I’m fine, just a little shy."
		],
		"npc_responses_wrong": [
			"I’m not quiet.",
			"Everything’s normal.",
			"I don’t feel shy today."
		]
	},

	{
		"id": "ask_shy_3",
		"text": "You look flustered. Did someone say something to you?",
		"expected_moods": ["shy"],
		"correct_effects": {"love": 2},
		"wrong_effects": {"trust": -1},
		"npc_responses_correct": [
			"Maybe… I’m just embarrassed.",
			"I got a little flustered earlier.",
			"You're right… something made me shy."
		],
		"npc_responses_wrong": [
			"Flustered? No.",
			"I’m not embarrassed.",
			"I don’t feel flustered."
		]
	},

	# ===================== ANNOYED =====================
	{
		"id": "ask_annoyed_1",
		"text": "You look annoyed. Did someone bother you?",
		"expected_moods": ["annoyed"],
		"correct_effects": {"trust": 1},
		"wrong_effects": {"love": -1},
		"npc_responses_correct": [
			"Yeah… someone irritated me.",
			"I’m annoyed, it’s been stressful.",
			"You’re right… I’m frustrated."
		],
		"npc_responses_wrong": [
			"Annoyed? No.",
			"I’m not upset.",
			"Nothing’s bothering me."
		]
	},

	{
		"id": "ask_annoyed_2",
		"text": "You seem frustrated today. Everything alright?",
		"expected_moods": ["annoyed"],
		"correct_effects": {"trust": 1},
		"wrong_effects": {"love": -1},
		"npc_responses_correct": [
			"I’m frustrated… it’s been a tough day.",
			"Yeah… I’m dealing with something annoying.",
			"I’m pretty irritated."
		],
		"npc_responses_wrong": [
			"Frustrated? Not really.",
			"I’m not angry.",
			"That’s not how I feel."
		]
	},

	{
		"id": "ask_annoyed_3",
		"text": "You look upset. Want to talk about it?",
		"expected_moods": ["annoyed"],
		"correct_effects": {"love": 1, "trust": 1},
		"wrong_effects": {"trust": -1},
		"npc_responses_correct": [
			"I might… it’s been bothering me.",
			"Yeah… something’s upsetting me.",
			"I could use someone to talk to."
		],
		"npc_responses_wrong": [
			"Upset? No.",
			"I’m not feeling that way.",
			"I’m fine, actually."
		]
	}
]

# Các pack riêng cho NPC (để trống, bạn thêm sau khi cần override)
const AMICE_GROVER_PACK = [
	# Ví dụ override/thêm riêng cho Amice đặt ở đây
]

const BLACKSMITH_RUDO_PACK = []
const INNKEEPER_LIA_PACK = []

# ===================== PUBLIC API =====================

static func get_pack(pack_id: StringName) -> Array:
	var packs := _packs()
	if packs.has(pack_id):
		return packs[pack_id]
	return packs.get(&"default", [])

static func get_for_npc(npc_key: StringName) -> Array:
	var map := _npc_to_pack()
	var pack_id: StringName = map.get(npc_key, &"default")
	return get_pack(pack_id)

static func get_merged_for_npc(npc_key: StringName, include_default := true) -> Array:
	var packs := _packs()
	var map := _npc_to_pack()
	var pack_id: StringName = map.get(npc_key, &"default")
	var base: Array = packs.get(&"default", []) if include_default else []
	var specific: Array = packs.get(pack_id, [])

	if not include_default:
		return specific.duplicate(true)
	if pack_id == &"default":
		return base.duplicate(true)

	var result: Array = []
	var index_by_id := {}

	for d in base:
		result.append(d)
		if typeof(d) == TYPE_DICTIONARY and d.has("id"):
			index_by_id[String(d["id"])] = result.size() - 1

	for d in specific:
		if typeof(d) == TYPE_DICTIONARY and d.has("id"):
			var k := String(d["id"])
			if index_by_id.has(k):
				result[index_by_id[k]] = d
			else:
				result.append(d)
		else:
			result.append(d)

	return result

# ===================== INTERNAL MAPS =====================

static func _packs() -> Dictionary:
	return {
		&"default": DEFAULT_PACK,
		&"amice_grover": AMICE_GROVER_PACK,
		&"blacksmith_rudo": BLACKSMITH_RUDO_PACK,
		&"innkeeper_lia": INNKEEPER_LIA_PACK,
	}

static func _npc_to_pack() -> Dictionary:
	return {
		&"AmiceGrover": &"amice_grover",
	}
