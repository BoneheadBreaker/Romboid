extends Area2D

@export var speed: float = 700.0
@export var hit_range: float = 80.0
var shooter_id: int = 0

func _process(delta: float) -> void:
	position += transform.x * speed * delta

func _on_body_entered(body: Node2D) -> void:
	var player = body
	if multiplayer.is_server():
		if not player is CharacterBody2D:
			return
		if player.name == str(shooter_id):
			return

		if global_position.distance_to(player.global_position) < hit_range:
			player.health = player.health - 50
			var pid = player.get_multiplayer_authority()
			var spawnpoint
			var team
			print(player.health)
			if player.health <= 0:
				var data = NetworkManager.players.get(pid)
				if data:
					spawnpoint = data.get("spawnpoint")
					team = data.get("team")
				
				player.queue_free()
				
				await get_tree().process_frame
				await get_tree().process_frame
				await get_tree().process_frame
				
				if spawnpoint:
					if pid:
						get_tree().get_root().get_node("Main/LoadedLevels/TestingMap").player_spawner.spawn([pid, spawnpoint, team])
			
			queue_free()
			return
