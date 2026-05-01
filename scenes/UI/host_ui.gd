extends Control

@onready var connected_players_label = $VBoxContainer/ConnectedPlayers
@onready var grid = $MarginContainer/ScrollContainer/GridContainer

@export var card_scene: PackedScene

var scene_names: Array[String] = []

var current_selected_map = null

func _ready() -> void:
	Signals.connect("map_selected", map_selected)
	get_builtin_maps()
	spawn_map_cards()

func get_builtin_maps():
	scene_names.clear()

	var path = "res://scenes/Maps"
	var dir = DirAccess.open(path)
	if dir == null:
		push_error("Cannot open directory: " + path)
		return

	dir.list_dir_begin()
	var file_name = dir.get_next()

	while file_name != "":
		if !dir.current_is_dir():
			if file_name.ends_with(".tscn"):
				scene_names.append(file_name.get_basename())

		file_name = dir.get_next()

	dir.list_dir_end()


func spawn_map_cards() -> void:
	for child in grid.get_children():
		child.queue_free()

	for scene_name in scene_names:
		var card = card_scene.instantiate()

		var path = "res://scenes/Maps/%s.tscn" % scene_name

		card.setup(scene_name, path)

		grid.add_child(card)

func _process(delta: float) -> void:
	connected_players_label.text = str(NetworkManager.players.size())

func map_selected(map_name):
	current_selected_map = map_name

func _on_start_game_button_pressed() -> void:
	Signals.start_game.emit(false, current_selected_map)
