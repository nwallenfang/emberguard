extends Spatial



onready var path_follow: PathFollow = $WagonPath/PathFollow

var wagon_speed: float = 2.5  # meter/s like a true physician
func start_wagon_path():
	pass



func _ready() -> void:
	Game.player = $Player
