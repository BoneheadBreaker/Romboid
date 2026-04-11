extends Node2D

@export var level_scene : PackedScene
@export var host_UI_scene : PackedScene
@export var join_UI_scene : PackedScene

@onready var UI_holder = $CanvasLayer

func _ready() -> void:
	Signals.connect("host_game_pressed", host_game_UI)
	Signals.connect("join_game_pressed", join_game_UI)
	
	Signals.connect("start_game", start_game)
	Signals.connect("join_game", join_game)

func host_game_UI():
	NetworkManager.create_game()

	print("added host game UI")
	var hostUI = host_UI_scene.instantiate()
	UI_holder.add_child(hostUI)
	
	UI_holder.get_node("MainMenu").queue_free()
	
func join_game_UI():
	print("added Join game UI")
	var joinUI = join_UI_scene.instantiate()
	UI_holder.add_child(joinUI)
	
	UI_holder.get_node("MainMenu").queue_free()

func start_game():
	load_game.rpc()
	
	UI_holder.get_node("HostUi").queue_free()
	NetworkManager.game_started = true

func join_game():
	NetworkManager.join_game()
	
	UI_holder.get_node("join_ui").queue_free()

@rpc("any_peer", "call_local", "reliable")
func load_game():
	if multiplayer.is_server():
		# only server loads scene. MultiplayerSpawner spawns it for everyone

		var level = level_scene.instantiate()
		$LoadedLevels.add_child(level)
		
		await get_tree().process_frame
		await get_tree().process_frame
		
		print("DEBUG: SPAWNING LEVEL")
