extends Control

func _ready() -> void:
	Signals.health_changed.connect(_on_health_changed)

func _on_health_changed(health):
	$ProgressBar.value = health
