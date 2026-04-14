extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_back_to_lobby_pressed() -> void:
	Signals.back_to_lobby.emit()


func _on_continue_anyway_pressed() -> void:
	Signals.start_game.emit(true)
