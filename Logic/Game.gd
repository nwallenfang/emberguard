extends Spatial

var player: Player

var fire_health := 1.0 setget set_fire_health

signal game_over


func game_over():
	get_tree().paused = true
	# TODO
	# mayyybe we will play some animation of the treasure being stolen
	# show some button to trigger restart
	

func set_fire_health(new_health: float):
	fire_health = clamp(new_health, 0.0, 1.0)
	
	
	if fire_health <= 0.0:
		emit_signal("game_over")
		game_over()
	
	UI.set_fire_health(fire_health)
	get_tree().current_scene.get_node("Wagon/Fire").set_fire_percent(fire_health)
	
	
	
	
func _process(delta: float) -> void:
	self.fire_health -= delta * 0.01

