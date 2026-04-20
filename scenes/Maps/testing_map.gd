extends Node2D

@onready var spawn_point_container: Node2D = $SpawnPoints
@onready var player_spawner: MultiplayerSpawner = $Players/PlayerSpawner

@export var player_scene : PackedScene

var team_spawnpoints := {
	1: [],
	2: []
	}
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()

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
	var pid_array := NetworkManager.players.keys()
	print(str(NetworkManager.players) + "ENDS HERE:")
	print("Players: ", pid_array)
	pid_array.sort() # this makes sure that the spawnpoints are in order. Not needed, just debug
	
	for node in spawn_point_container.get_children():
		if node.name.begins_with("TEAM_1"):
			team_spawnpoints[1].append(node)
		elif node.name.begins_with("TEAM_2"):
			team_spawnpoints[2].append(node)
			
	for i in range(pid_array.size()):
		var pid = pid_array[i]

		var team = (i % 2) + 1

		if pid in NetworkManager.players:
			NetworkManager.players[pid]["team"] = team

		var spawnpoint = get_spawnpoint(team)

		player_spawner.spawn([pid, spawnpoint, team])

func get_spawnpoint(team: int) -> Vector2:
	var pool = team_spawnpoints.get(team, [])

	if pool.is_empty():
		push_error("No available spawnpoints for team " + str(team))
		return Vector2.ZERO

	var node = pool[0]

	pool.remove_at(0)

	return node.global_position
	
func spawn_player(data):
	print("BEFORE: " + str(NetworkManager.players))

	var player = player_scene.instantiate()
	var pid = data[0]
	var spawnpoint = data[1]
	var team = data[2]

	player.add_to_group("team_" + str(team))

	player.position = spawnpoint
	player.name = str(pid)
	print(pid)
	player.set_multiplayer_authority(pid)
	
	print("AFTER: " + str(NetworkManager.players))
	
	return player
