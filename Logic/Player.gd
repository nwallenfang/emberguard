extends PhysicsMover3D

class_name Player

enum State {
	DEFAULT
}

var state = State.DEFAULT

# movement parameters
export var CONTROLS_ENABLED := true
export var move_acceleration = 100.0
export var dash_acceleration = 3000.0
export var air_acceleration = 120.0
export var jump_total_acceleration = 7200.0
export var jump_total_number_of_frames = 6
export var ground_dampening = 0.7


func _ready() -> void:
#	$DustTrack.set_as_toplevel(true)
	pass

var jump_frame_count := -1
func handle_input(delta):
	if not CONTROLS_ENABLED:
		return
		
	var move_direction := Vector3.ZERO
	move_direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	move_direction.z = Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")
	
	move_direction = move_direction.normalized()

	add_acceleration(move_acceleration * move_direction)

	var look_direction := -Vector3(acceleration)
	var look_vec2 := Vector2(acceleration.x, acceleration.z)
#	var own_vec2 := Vector2(self.translation.x, self.translation.z)
	
	var angular_velocity := 30.0
	if look_vec2 != Vector2.ZERO:
		rotation.y = lerp_angle(rotation.y, atan2(-look_direction.x, -look_direction.z), angular_velocity * delta)
		


func state_default(delta):
	handle_input(delta)
	execute_movement(delta)
	

func match_state(delta):
	match state:
		State.DEFAULT:
			state_default(delta)
	

func _physics_process(delta: float) -> void:
	match_state(delta)

var item_holded := ""
var item_holded_count := 0

func hold_item(item_name:String):
	pass

func loose_item():
	pass

func drop_item():
	pass

