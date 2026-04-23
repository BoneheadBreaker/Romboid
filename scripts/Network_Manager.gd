extends Node

@onready var scene_root = get_tree().get_root() 

signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)

const DEFAULT_PORT = 36666
const DEFAULT_SERVER_IP = "127.0.0.1" # IPv4 localhost
const MAX_CONNECTIONS = 5

var players = {}
var connection_type := "player"
var game_started = false

# Scenes
var player_scene = preload("res://scenes/player.tscn")
var level_scene = preload("res://scenes/Maps/testing_map.tscn")
var bullet_scene = preload("res://scenes/bullet.tscn")

var players_container

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok) # only runs on client once its connected
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func join_game(address = "", port = ""):
	print("Joining")
	if address.is_empty():
		address = DEFAULT_SERVER_IP
	if port.is_empty():
		port = DEFAULT_PORT
		
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, port)
	if error:
		print("Couldnt join")
		return error
	multiplayer.multiplayer_peer = peer
	
func create_game():
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(DEFAULT_PORT, MAX_CONNECTIONS)
	if error:
		return error
	multiplayer.multiplayer_peer = peer

	_register_player(connection_type)

# Adds player to lobby but not the game world
@rpc("any_peer", "reliable")
func _register_player(new_player_info):
	if not multiplayer.is_server():
		return
		
	var new_player_id = multiplayer.get_remote_sender_id()


	if multiplayer.is_server() and new_player_id == 0:
		new_player_id = multiplayer.get_unique_id()

	var player_data := {
		"type": new_player_info,
		"team": null,
		"spawnpoint": null,
		"deaths": null
	}

	players[new_player_id] = player_data
	player_connected.emit(new_player_id, player_data)

@rpc("authority", "call_remote", "reliable")
func game_already_started():
	print("The server told me the game has already started!")
	Signals.game_already_started.emit()
	multiplayer.multiplayer_peer.close() 

@rpc("any_peer", "call_local", "reliable")
func load_game():
	if multiplayer.is_server():
		# only server loads scene. MultiplayerSpawner spawns it for everyone

		var level = level_scene.instantiate()
		scene_root.get_node("Main/LoadedLevels").add_child(level)
		
		await get_tree().process_frame
		await get_tree().process_frame

@rpc("any_peer", "call_local", "reliable")
func request_bullet(rot):
	if multiplayer.is_server():
		players_container = scene_root.get_node("Main/LoadedLevels/TestingMap/Players/")
		
		var sender_id = multiplayer.get_remote_sender_id()
		var player = players_container.get_node_or_null(str(sender_id))
		if not player:
			print("Server: Player not found:", sender_id)
			return
			
		# Instantiate bullet
		var bullet = bullet_scene.instantiate()
		bullet.global_position = player.global_position
		bullet.rotation = rot
		bullet.shooter_id = sender_id

		# Add to server-side bullets container (normal add_child)
		var bullets_node = scene_root.get_node("Main/LoadedLevels/TestingMap/Bullets")
		bullets_node.add_child(bullet, true)

		# Optional: add to group for server-side collision
		bullet.add_to_group("Bullets")

@rpc("any_peer", "call_local")
func spawn_bullet_on_client(shooter_id: int, pos: Vector2, rot: float) -> void:
	# Clients spawn a **local copy** for visuals only
	var bullet = bullet_scene.instantiate()
	bullet.global_position = pos
	bullet.rotation = rot
	bullet.shooter_id = shooter_id
	scene_root.get_node("Main/LoadedLevels/TestingMap/Bullets").add_child(bullet)


# When a peer connects, send them my player info.
# This allows transfer of all desired data for each player, not only the unique ID.
func _on_player_connected(id):
	_register_player.rpc_id(id, connection_type)
	
	if multiplayer.is_server():
		if NetworkManager.game_started == true:
			game_already_started.rpc_id(id)

func _on_player_disconnected(id):
	print("Player ", id, " Left")
	players.erase(id)
	player_disconnected.emit(id)


func _on_connected_ok():
	print("Connected")

func _on_connected_fail():
	print("Couldn't Join")
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()


func _on_server_disconnected():
	print("Server Disconnected")
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	players.clear()
	Signals.server_disconnected.emit()
