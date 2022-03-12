extends CanvasLayer


func _ready() -> void:
	Game.connect("game_over", self, "game_over")
	Game.connect("main_game_started", self, "main_game_started")

func set_fire_health(fire_health: float):
	# TODO maybe have the fire icon blink or smth
	$FireHealthbar.material.set_shader_param("value", fire_health)

export var too_much_to_carry_length := 2.0
var too_much_to_carry_time_left = 0.0
func trigger_too_much_to_carry():
	too_much_to_carry_time_left = too_much_to_carry_length

export var cannot_attack_length := 2.0
var cannot_attack_time_left = 0.0
func trigger_cannot_attack():
	cannot_attack_time_left = cannot_attack_length

func hit_effect():
	$HitEffect.visible = true
	$HitEffectTween.interpolate_property($HitEffect, "modulate:a", .3, .0, .6)
	$HitEffectTween.start()
	yield($HitEffectTween,"tween_all_completed")
	$HitEffect.visible = false

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("magician_msg"):
		magician_event_message()
	$FireHealthbar/FPSCounter.text = "FPS: " + String(Engine.get_frames_per_second())
	if $CenterContainer/GameOverBox/RestartButton.disabled == false and $CenterContainer/GameOverBox.visible:
		if Input.is_action_just_pressed("ui_accept"):
			_on_RestartButton_pressed()
	
	if Input.is_action_just_pressed("pause"):
		# dont pause if it's game over
		if not $CenterContainer/GameOverBox.visible:
			get_tree().paused = not get_tree().paused
			$PauseView.visible = get_tree().paused
	
	update_wagon_marker()
	
	if too_much_to_carry_time_left > .1:
		$TooMuchToCarry.visible = true
		too_much_to_carry_time_left -= _delta
		$TooMuchToCarry.modulate.a = too_much_to_carry_time_left / too_much_to_carry_length
	else:
		$TooMuchToCarry.visible = false
	
	if cannot_attack_time_left > .1:
		$CannotAttack.visible = true
		cannot_attack_time_left -= _delta
		$CannotAttack.modulate.a = cannot_attack_time_left / cannot_attack_length
	else:
		$CannotAttack.visible = false
		
		
func magician_event_message():
	$Tween.reset_all()
	var label: Label
	if Game.player.get_node("Weapon").type != Game.player.get_node("Weapon").TYPE.Empty:
		# player has weapon
		label = $EventMessage
	else: # no weapon
		label = $EventMessageNoWeapon
	
	label.visible = true
	yield(get_tree().create_timer(3.0), "timeout")
	$CutsceneTween.interpolate_property(label, "modulate", blended_in, blended_out, 2.0)
	$CutsceneTween.start()
	yield($CutsceneTween, "tween_all_completed")
	label.visible = false
	

func main_game_started():
	$IntroPressAnyKey.visible = false
	$WagonMarker.visible = true
	$FireHealthbar.visible = true

	yield(get_tree().create_timer(2.0), "timeout")
	$ProtectTheFire.visible = true	
	var mod = $ProtectTheFire.modulate
	var mod1 = mod
	mod1.a = 0.0
	yield(get_tree().create_timer(2.0), "timeout")
	$ProtectTween.interpolate_property($ProtectTheFire, "modulate", mod, mod1, 5.5, Tween.TRANS_CUBIC, Tween.EASE_IN)
	$ProtectTween.start()
	yield($ProtectTween,"tween_all_completed")
	$ProtectTheFire.visible = false

export var wagon_marker_border := 200
export var wagon_marker_distance := 14.0
func update_wagon_marker():
	if Game.player_distance_to_wagon < wagon_marker_distance:
		$WagonMarker.visible = false
		return
	$WagonMarker.visible = true
	
	#var dir = randf() * 2 * PI
	var dir_vector = Game.player.translation.direction_to(Game.wagon.translation)#Vector2.UP.rotated(dir)
	
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

func game_over():  # lost
	$CenterContainer/GameOverBox.visible = true
	$CenterContainer/GameOverBox/RestartButton.disabled = false

var blended_in = Color(1.0, 1.0, 1.0, 1.0)
var blended_out = Color(1.0, 1.0, 1.0, 0.0)
var credit1_duration = 5.0
var credit2_duration = 5.0
func game_end_won():  # won
	var viewportWidth = get_viewport().size.x
	var viewportHeight = get_viewport().size.y
	for sprite in [$ColorRect/Credit1, $ColorRect/Credit2]:
		var scale = viewportWidth / sprite.texture.get_size().x
		sprite.set_position(Vector2(viewportWidth/2, viewportHeight/2))

		# set same scale value horizontally/vertically to maintain aspect ratio
		sprite.set_scale(Vector2(scale, scale))

	# show first credit
	$ColorRect.modulate = blended_out
	$ColorRect.set_deferred("visible", true)
	$Tween.reset_all()
	$Tween.interpolate_property($ColorRect, "modulate", blended_out, blended_in, 0.4, Tween.EASE_IN)
	$Tween.start()
	yield(get_tree().create_timer(credit1_duration), "timeout")
	
	# show second credit
	$Tween.reset_all()
	$Tween.interpolate_property($ColorRect/Credit1, "modulate", blended_in, blended_out, 1.0, Tween.EASE_OUT)
	$Tween.start()
	$ColorRect/Credit2.modulate = blended_out
	$ColorRect/Credit2.set_deferred("visible", true)
	$Tween2.reset_all()
	$Tween2.interpolate_property($ColorRect/Credit2, "modulate", blended_out, blended_in, 0.4, Tween.EASE_IN)
	$Tween2.start()

	yield(get_tree().create_timer(credit1_duration), "timeout")	
	# fade to black
	$Tween.reset_all()
	$Tween.interpolate_property($ColorRect/Credit2, "modulate", blended_in, blended_out, 2.5, Tween.EASE_OUT)
	$Tween.start()
	
	get_tree().quit()


func _on_RestartButton_pressed() -> void:
	get_tree().paused = false
	Game.reset()
	$CenterContainer/GameOverBox.visible = false
	var _err = get_tree().reload_current_scene()

func show_attack_tutorial():
	$AttackWith.visible = true
	$AttackWith/Tween.interpolate_property($AttackWith, "modulate:a", 1.0, 0.0, 3.5)
	$AttackWith/Tween.start()
	yield($AttackWith/Tween, "tween_all_completed")
	$AttackWith.visible = false

func set_interact_text(text:String):
	$InteractLabel.visible = text != ""
	$InteractLabel.text = "Press E to " + text


func _on_SFXSlider_value_changed(value: float) -> void:
	var index = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_volume_db(index, linear2db(value))


func _on_MusicSlider_value_changed(value: float) -> void:
	var index = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(index, linear2db(value))
