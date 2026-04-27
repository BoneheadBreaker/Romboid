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
			player.health -= 50
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
				
				if spawnpoint:
					if pid:
						# 1. Pull the current revives from your PERSISTENT data
						var revives = data.get("revives", 3) 
						revives -= 1
						
						# 2. Save it back to the dictionary immediately
						data["revives"] = revives
						print("Player " + str(pid) + " has " + str(revives) + " revives left.")
						
						check_for_winner()
						
						# 3. Check if they are actually out of the game
						if revives <= 0:
							print("Player " + str(pid) + " is permanently out!")
							player.queue_free()
							queue_free()
							return
						
						# Hide it so it's "gone" for players
						visible = false 
						# Disable collisions so it can't hit anyone else
						$CollisionShape2D.set_deferred("disabled", true)
						
						await get_tree().create_timer(3.0).timeout  # Wait for 3 seconds
						get_tree().get_root().get_node("Main/LoadedLevels/TestingMap").player_spawner.spawn([pid, spawnpoint, team])
			
			queue_free()
			return

func check_for_winner():
	if not multiplayer.is_server():
		return
	var team1_alive = false
	var team2_alive = false

	# Loop through every player in your data dictionary
	for id in NetworkManager.players:
		var data = NetworkManager.players[id]
		var team = data.get("team")
		var revives = data.get("revives", 0)

		# If anyone on the team has lives left, that team is still in
		if revives > 0:
			if team == 1:
				team1_alive = true
			elif team == 2:
				team2_alive = true

	# Check the results
	if not team1_alive:
		print("TEAM 2 WINS! Team 1 is out of lives.")
		NetworkManager.display_game_over_ui.rpc(2)
	elif not team2_alive:
		print("TEAM 1 WINS! Team 2 is out of lives.")
		NetworkManager.display_game_over_ui.rpc(1)
