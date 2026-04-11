extends Node

signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected

const DEFAULT_PORT = 36666
const DEFAULT_SERVER_IP = "127.0.0.1" # IPv4 localhost, replace with server
const MAX_CONNECTIONS = 5

var players = {}
var connection_type := "player"

# Scenes
var player_scene = preload("res://scenes/player.tscn")
var game_started = false

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

	players[1] = connection_type
	player_connected.emit(1, connection_type)

# Adds player to lobby but not the game world
@rpc("any_peer", "reliable")
func _register_player(new_player_info):
	var new_player_id = multiplayer.get_remote_sender_id()
	players[new_player_id] = new_player_info
	player_connected.emit(new_player_id, new_player_info)

# When a peer connects, send them my player info.
# This allows transfer of all desired data for each player, not only the unique ID.
func _on_player_connected(id):
	_register_player.rpc_id(id, connection_type)
	
	if multiplayer.is_server():
		if NetworkManager.game_started == true:
			multiplayer.multiplayer_peer.disconnect_peer(id)

func _on_player_disconnected(id):
	print("Player ", id, " Left")
	players.erase(id)
	player_disconnected.emit(id)


func _on_connected_ok():
	print("Connected")
	var peer_id = multiplayer.get_unique_id()
	players[peer_id] = connection_type
	player_connected.emit(peer_id, connection_type)


func _on_connected_fail():
	print("Couldn't Join")
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()


func _on_server_disconnected():
	print("Server Disconnected")
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	players.clear()
	server_disconnected.emit()
