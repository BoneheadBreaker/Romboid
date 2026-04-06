extends Control

func _on_host_pressed() -> void:
	Signals.host_game_pressed.emit()

func _on_join_pressed() -> void:
	Signals.join_game_pressed.emit()
