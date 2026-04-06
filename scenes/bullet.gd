extends Area2D

@export var speed: float = 700.0
@export var hit_range: float = 80.0
var shooter_id: int = 0

func _process(delta: float) -> void:
	position += transform.x * speed * delta
	if multiplayer.is_server():
		_check_hits()

func _check_hits() -> void:
	for player in get_parent().get_children():
		if not player is CharacterBody2D:
			continue
		if player.name == str(shooter_id):
			continue
		if global_position.distance_to(player.global_position) < hit_range:
			player.take_damage(10)
			queue_free()
			return
