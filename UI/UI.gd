extends CanvasLayer


func _ready() -> void:
	Game.connect("game_over", self, "game_over")
	Game.connect("main_game_started", self, "main_game_started")


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
	
	update_wagon_marker()


func main_game_started():
	$IntroPressAnyKey.visible = false
	$WagonMarker.visible = true
	$FireHealthbar.visible = true
	$FPSCounter.visible = true

export var wagon_marker_border := 200
export var wagon_marker_distance := 10.0
func update_wagon_marker():
	if Game.player_distance_to_wagon < wagon_marker_distance:
		$WagonMarker.visible = false
		return
	$WagonMarker.visible = true
	
	#var dir = randf() * 2 * PI
	var dir_vector = Game.wagon.translation.direction_to(Game.player.translation)#Vector2.UP.rotated(dir)
	
	dir_vector = Vector2(dir_vector.x, dir_vector.z)
	
	if (dir_vector.x * dir_vector.y == 0): #for dividing with 0 issues
		dir_vector = dir_vector.rotated(deg2rad(1))
	
	var view_size_small = (get_viewport().size - Vector2(1,1) * wagon_marker_border) / 2
	var view_size_normal = get_viewport().size
	var h1 = view_size_small.y / dir_vector.y
	var h2 = -view_size_small.y / dir_vector.y
	var v1 = view_size_small.x / dir_vector.x
	var v2 = -view_size_small.x / dir_vector.x
	var result = Vector2(0,0)
	for factor in [h1, h2, v1, v2]:
		if factor <= 0:
			continue
		var test = dir_vector * factor
		if abs(test.x) > view_size_small.x + 1:
			continue
		if abs(test.y) > view_size_small.y + 1:
			continue
		result = test
	
	$WagonMarker.position = (view_size_normal / 2) + result
	$WagonMarker.rotation_degrees = rad2deg(dir_vector.angle())


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
