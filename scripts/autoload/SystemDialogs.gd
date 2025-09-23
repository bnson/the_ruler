### 📄 SystemDialogs.gd (Autoload)
extends CanvasLayer

@onready var accept_dialog: AcceptDialog = $AcceptDialog
@onready var confirmation_dialog: ConfirmationDialog = $ConfirmationDialog

signal confirmation_finished(result: bool)

func _ready():
	confirmation_dialog.connect("confirmed", Callable(self, "_on_confirmation_confirmed"))
	confirmation_dialog.connect("canceled", Callable(self, "_on_confirmation_canceled"))

func show_message(text: String, title: String = "") -> void:
	accept_dialog.title = title
	accept_dialog.dialog_text = text
	accept_dialog.popup_centered()

func confirm(text: String, title: String = "") -> bool:
	confirmation_dialog.title = title
	confirmation_dialog.dialog_text = text
	confirmation_dialog.popup_centered()
	var result = await confirmation_finished
	return result

func _on_confirmation_confirmed() -> void:
	emit_signal("confirmation_finished", true)

func _on_confirmation_canceled() -> void:
	emit_signal("confirmation_finished", false)
