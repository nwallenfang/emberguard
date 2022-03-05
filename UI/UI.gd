extends CanvasLayer


func _ready() -> void:
	Game.connect("game_over", self, "game_over")


func set_fire_health(fire_health: float):
	# TODO maybe have the fire icon blink or smth
	$FireHealthbar.material.set_shader_param("value", fire_health)


func _process(_delta: float) -> void:
	$FPSCounter.text = "FPS: " + String(Engine.get_frames_per_second())
	
	if Input.is_action_just_pressed("pause"):
		# dont pause if it's game over
		if not $CenterContainer/GameOverBox.visible:
			get_tree().paused = not get_tree().paused
			$CenterContainer/PausedLabel.visible = get_tree().paused


func game_over():
	$CenterContainer/GameOverBox.visible = true
	$CenterContainer/GameOverBox/RestartButton.disabled = false


func _on_RestartButton_pressed() -> void:
	get_tree().paused = false
	Game.reset()
	$CenterContainer/GameOverBox.visible = false
	var _err = get_tree().reload_current_scene()
	



func set_interact_text(text:String):
	$InteractLabel.visible = text != ""
	$InteractLabel.text = "Press E to " + text
