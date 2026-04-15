extends Node2D

@onready var spawn_point_container: Node2D = $SpawnPoints
@onready var player_spawner: MultiplayerSpawner = $Players/PlayerSpawner

@export var player_scene : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	player_spawner.spawn_function = Callable(self, "spawn_player")
	if multiplayer.is_server():
		await get_tree().process_frame
		await get_tree().process_frame
		await get_tree().process_frame
		spawn_all_players()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func spawn_all_players():
	print("Spawner authority:", player_spawner.get_multiplayer_authority())
	print("My peer ID:", multiplayer.get_unique_id())
	print("ABC " + str(spawn_point_container))
	var spawnpoints := spawn_point_container.get_children()
	var pid_array := NetworkManager.players.keys()
	print(str(NetworkManager.players) + "ENDS HERE:")
	print("Players: ", pid_array)
	pid_array.sort()  
	# this makes sure that the spawnpoints are in order. Not needed, just debug
	
	for i in range(pid_array.size()):
		var pid = pid_array[i]
		var spawnpoint = spawnpoints[i].global_position
		
		player_spawner.spawn([pid, spawnpoint])

func spawn_player(data):
	var player = player_scene.instantiate()
	var pid = data[0]
	var spawnpoint = data[1]
	player.position = spawnpoint
	player.name = str(pid)
	print(pid)
	player.set_multiplayer_authority(pid)

	return player
