extends NPC
class_name AmiceGrover

@onready var node_name := get_name()

func _ready():
	super()
	display_name = "Amice Grover"
	display_info = "She is a friendly and diligent shopkeeper, always welcoming customers with a warm smile and a helpful hand. Running the general store is not just her duty but her joy; she finds genuine delight in the art of trading and the rhythm of daily business.\nThough hardworking, she has a playful streak—often teasing customers with light sarcasm or witty remarks, especially when they try to haggle. In fact, she secretly enjoys “reverse bargaining”: she might raise the price at first with a smirk, only to drop it later and laugh at the customer’s reaction.\nShe is also known to be a chatterbox, happily sharing the latest gossip and small-town news with anyone who lingers at the counter. Yet beneath her cheerful demeanor, she is mildly suspicious of strangers; it takes time and consistent honesty for her to fully open up and trust someone."

	# ✅ Chỉ gán nếu ItemDatabase đã sẵn sàng
	if ItemDatabase.is_ready():
		sell_items = [
			ItemDatabase.get_item("apple")
		]
	else:
		push_warning("⚠ ItemDatabase chưa sẵn sàng khi AmiceGrover khởi tạo.")
