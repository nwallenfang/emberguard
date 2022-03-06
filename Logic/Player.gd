extends PhysicsMover3D

class_name Player

enum State {
	DEFAULT,
	STUNNED
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

export var knockback_acc := 1600.0

export var stun_time = 1.0
export var invinc_time = 2.0

onready var scent_emitter := $ScentEmitter

export var god_mode: bool = true

func _ready():
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
	
func state_stunned(delta):
	execute_movement(delta)

func match_state(delta):
	match state:
		State.DEFAULT:
			state_default(delta)
		State.STUNNED:
			state_stunned(delta)

func _physics_process(delta: float) -> void:
#	print("hurtbox active: ")
	match_state(delta)

var item_holded := ""
var item_holded_count := 0

var item_visible := ""
var item_visible_count := 0
func update_holding_hand():
	if item_holded_count != item_visible_count or item_holded != item_visible:
		for c in $ItemHand.get_children():
			c.queue_free()
		if item_holded_count != 0:
			var item = make_item(item_holded, false)
			item.make_flying()
			$ItemHand.add_child(item)
	
	item_visible = item_holded
	item_visible_count = item_holded_count

func hold_item(item_name:String):
	if item_holded_count == 0:
		item_holded = item_name
		item_holded_count = 1
	else:
		if item_holded == item_name:
			item_holded_count += 1
		else:
			drop_item()
			item_holded = item_name
			item_holded_count = 1
	update_holding_hand()

func loose_item():
	item_holded = ""
	item_holded_count = 0
	update_holding_hand()

const LOG = preload("res://Objects/Items/Log.tscn")
const PLANT = preload("res://Objects/Items/Plant.tscn")
func make_item(custom_item = "", add_to_tree_scene = true) -> Spatial:
	var item_name = item_holded
	if custom_item != "":
		item_name = custom_item
	var inst = null
	match item_name:
		"log":
			inst = LOG.instance()
		"plant":
			inst = PLANT.instance()
	if inst != null and add_to_tree_scene:
		get_tree().current_scene.add_child(inst)
	return inst

func drop_item():
	var dropped_item = make_item()
	dropped_item.translation = translation + Vector3(0, .1, 0)
	loose_item()



func _on_Hurtbox_area_entered(area: Area) -> void:
	if god_mode:
		return
	if not area.name == "Hitbox":
		return # dirty but ok for now
	$HurtParticles.emitting = true	
	var knockback_direction = area.global_transform.origin.direction_to(self.global_transform.origin)
	add_acceleration(knockback_acc * knockback_direction)
	state = State.STUNNED	
	$InvincibilityTimer.start(invinc_time)
	$Hurtbox.set_deferred("monitoring", false)
	$Hurtbox.set_deferred("monitorable", false)
	$StunnedTimer.start(stun_time)  # when this timeouts you are not stunned anymore
	# player is immediately stunned but wait a little for the stunnedparticles to show
	yield(get_tree().create_timer(0.2), "timeout")
	$StunnedParticles.emitting = true


	


func _on_StunnedTimer_timeout() -> void:
	state = State.DEFAULT
	$StunnedParticles.emitting = false


func _on_InvincibilityTimer_timeout() -> void:
	$Hurtbox.set_deferred("monitoring", true)
	$Hurtbox.set_deferred("monitorable", true)
