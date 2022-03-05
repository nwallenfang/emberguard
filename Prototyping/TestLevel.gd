extends Spatial


func _ready() -> void:
	Game.player = $Player
	Game.wagon = $Wagon
	Game.ground_aabb = $Ground.get_transformed_aabb()
