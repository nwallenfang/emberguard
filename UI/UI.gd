extends CanvasLayer


func _ready() -> void:
	Game.connect("game_over", self, "game_over")


func set_fire_health(fire_health: float):
	# TODO maybe have the fire icon blink or smth
	$FireHealthbar.material.set_shader_param("value", fire_health)


func _process(delta: float) -> void:
	$FPSCounter.text = "FPS: " + String(Engine.get_frames_per_second())


func game_over():
	$CenterContainer/GameOverBox.visible = true
	$CenterContainer/GameOverBox/RestartButton.disabled = false



func _on_RestartButton_pressed() -> void:
	get_tree().reload_current_scene()
