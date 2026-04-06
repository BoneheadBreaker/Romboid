extends CharacterBody2D

@export var syncPos := Vector2(0.0, 0.0)

func _ready() -> void:
	syncPos = global_position
	
	$PlayerID.text = name
	NetworkManager.player_disconnected.connect(_on_player_disconnected)
	
func _physics_process(delta: float) -> void:
		
	if not is_multiplayer_authority():
		# Making it 30fps (save bandwidth) and lerping with local fps to hide the stutter
		position = lerp(position, syncPos, 0.5)
		return
	
	var speed := 200.0
	velocity = Vector2.ZERO

	if Input.is_action_pressed("W"):
		velocity.y -= 1
	if Input.is_action_pressed("S"):
		velocity.y += 1
	if Input.is_action_pressed("A"):
		velocity.x -= 1
	if Input.is_action_pressed("D"):
		velocity.x += 1

	velocity = velocity.normalized() * speed
	
	syncPos = global_position
	move_and_slide()
	
func _on_player_disconnected(pid) -> void:
	if pid == int(name):
		Globals.player_info.erase(pid)
		queue_free()
	pass
