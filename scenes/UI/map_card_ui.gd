extends Button

@onready var label = $VBoxContainer/Label

var map_name: String
var scene_path: String

func setup(name: String, path: String) -> void:
	# warning @onready variables may not be ready here
	
	map_name = name
	scene_path = path

func _ready() -> void:
	label.text = map_name
