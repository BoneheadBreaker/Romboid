extends Control

@onready var connected_players_label = $CenterContainer/VBoxContainer/ConnectedPlayers

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	connected_players_label.text = str(NetworkManager.players.size())
	print(str(NetworkManager.players.size()))


func _on_start_game_button_pressed() -> void:
	Signals.start_game.emit()
