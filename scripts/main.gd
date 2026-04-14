extends Node2D

@export var level_scene : PackedScene
@export var host_UI_scene : PackedScene
@export var join_UI_scene : PackedScene
var game_already_started_ui_scene = preload("res://scenes/UI/game_already_started_ui.tscn")
var main_menu = preload("res://scenes/UI/main_menu.tscn")
var odd_number_of_players_ui_scene = preload("res://scenes/UI/odd_players_ui.tscn")

@onready var UI_holder = $CanvasLayer

func _ready() -> void:
	Signals.connect("host_game_pressed", host_game_UI)
	Signals.connect("join_game_pressed", join_game_UI)
	
	Signals.connect("start_game", check_if_can_start_game)
	Signals.connect("join_game", join_game)
	
	Signals.connect("game_already_started", game_already_started)
	Signals.connect("back_to_menu", go_back_to_menu)
	Signals.connect("back_to_lobby", go_back_to_lobby)

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

func game_already_started():
	var GameAlreadyStartedUI = game_already_started_ui_scene.instantiate()
	UI_holder.add_child(GameAlreadyStartedUI)

func go_back_to_menu():
	var all_uis = UI_holder.get_children()
	for node in all_uis:
		node.queue_free()
	
	var mainUI = main_menu.instantiate()
	UI_holder.add_child(mainUI)

func start_game():
	print("second run")
	NetworkManager.load_game.rpc()
	
	var all_uis = UI_holder.get_children()
	for node in all_uis:
		node.queue_free()
		
	NetworkManager.game_started = true

func check_if_can_start_game(override_odd_players):
	print("running")
	if override_odd_players == true:
		start_game()
	elif Globals.is_even(NetworkManager.players.size()) and override_odd_players == false:
		start_game()
	else:
		var all_uis = UI_holder.get_children()
		for node in all_uis:
			node.queue_free()
		
		var OddPlayersUI = odd_number_of_players_ui_scene.instantiate()
		UI_holder.add_child(OddPlayersUI)

func join_game():
	NetworkManager.join_game()
	
	UI_holder.get_node("join_ui").queue_free()

func go_back_to_lobby():
	var all_uis = UI_holder.get_children()
	for node in all_uis:
		node.queue_free()
	
	var HostUI = host_UI_scene.instantiate()
	UI_holder.add_child(HostUI)
