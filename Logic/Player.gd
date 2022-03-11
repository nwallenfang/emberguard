extends PhysicsMover3D

class_name Player

enum State {
	DEFAULT,
	STUNNED,
	ATTACK
}

var state = State.DEFAULT

# movement parameters
export var CONTROLS_ENABLED := true
export var base_move_acceleration := 100.0
var move_acceleration = base_move_acceleration
export var dash_acceleration := 3000.0
export var air_acceleration = 120.0
export var jump_total_acceleration = 7200.0
export var jump_total_number_of_frames = 6
export var ground_dampening = 0.7

export var knockback_acc := 1600.0

export var stun_time = 2.0
export var invinc_time = 3.0

onready var scent_emitter := $ScentEmitter

export var god_mode: bool = true

func _ready():
	pass

signal cannot_attack

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
	
	var angular_velocity := 20.0
	if look_vec2 != Vector2.ZERO:
		rotation.y = lerp_angle(rotation.y, atan2(-look_direction.x, -look_direction.z), angular_velocity * delta)
	
	if Input.is_action_just_pressed("attack"):
		if item_holded_count == 0:
			if $Weapon.type != Weapon.TYPE.Empty and not state == State.ATTACK:
				state = State.ATTACK
			else:
#				emit_signal("cannot_attack")
				# don't show cannot attack prompt if not holding a weapon
				pass
		else:
			emit_signal("cannot_attack")


func state_default(delta):
	handle_input(delta)
	execute_movement(delta)

func state_stunned(delta):
	execute_movement(delta)

func play_random_attack_sound():
	var index = randi() % 3 + 1
	$AttackSounds.get_node("AttackSound" + String(index)).play()

var first_frame_attack := true
func state_attack(delta):
	if first_frame_attack:
		first_frame_attack = false
		#$PlayerAttack.visible = true
		play_random_attack_sound()
		$WeaponAnimationPlayer.play("attack")
		$PlayerAttack/PlayerAttackArea.set_deferred("monitoring", true)
		$PlayerAttack/PlayerAttackArea.set_deferred("monitorable", true)
		$PlayerAttack/AttackTimer.start()
	handle_input(delta)
	execute_movement(delta)

func _on_AttackTimer_timeout():
	state = State.DEFAULT
	first_frame_attack = true
	$PlayerAttack.visible = false
	$PlayerAttack/PlayerAttackArea.set_deferred("monitoring", false)
	$PlayerAttack/PlayerAttackArea.set_deferred("monitorable", false)

func match_state(delta):
	match state:
		State.DEFAULT:
			state_default(delta)
		State.STUNNED:
			state_stunned(delta)
		State.ATTACK:
			state_attack(delta)

func _physics_process(delta: float) -> void:
#	print("hurtbox active: ")
	match_state(delta)

var item_holded := ""
var item_holded_count := 0

var item_visible := ""
var item_visible_count := 0
var stack_offset := .24
export var item_speed_punishment := 10.0
func update_holding_hand():
	if item_holded_count != item_visible_count or item_holded != item_visible:
		for c in $ItemHand.get_children():
			c.queue_free()
		for i in range(item_holded_count):
			var item = make_item(item_holded, false, 1)
			item.make_flying()
			$ItemHand.add_child(item)
			item.translation += Vector3(0, stack_offset, 0) * i
	move_acceleration = base_move_acceleration - item_holded_count * item_speed_punishment
	if item_holded_count == 0:
		$Weapon.visible = true
	else:
		$Weapon.visible = false
	item_visible = item_holded
	item_visible_count = item_holded_count

signal too_much_to_carry

func try_hold_item(item_name:String):
	if item_holded_count == 0:
		item_holded = item_name
		item_holded_count = 1
	else:
		if item_holded == item_name:
			if item_name == "log" and item_holded_count <3:
				item_holded_count += 1
			else:
				emit_signal("too_much_to_carry")
				return false
		else:
			drop_item()
			item_holded = item_name
			item_holded_count = 1
	update_holding_hand()
	$PickUpPlayer.play()
	return true

func loose_item():
	item_holded = ""
	item_holded_count = 0
	update_holding_hand()

const LOG = preload("res://Objects/Items/Log.tscn")
const LOG2 = preload("res://Objects/Items/LogStack2.tscn")
const LOG3 = preload("res://Objects/Items/LogStack3.tscn")
const PLANT = preload("res://Objects/Items/Plant.tscn")
const FRUIT_PILE = preload("res://Objects/Items/FruitPile.tscn")
func make_item(custom_item = "", add_to_tree_scene = true, count = 0) -> Spatial:
	if count == 0:
		count = item_holded_count
	var item_name = item_holded
	if custom_item != "":
		item_name = custom_item
	var inst = null
	match item_name:
		"log":
			match count:
				1:
					inst = LOG.instance()
				2:
					inst = LOG2.instance()
				3:
					inst = LOG3.instance()
		"plant":
			inst = PLANT.instance()
		"fruit_pile":
			inst = FRUIT_PILE.instance()
	if inst != null and add_to_tree_scene:
		get_tree().current_scene.add_child(inst)
	return inst

func drop_item():
	if item_holded_count == 0:
		return
	var dropped_item = make_item()
	dropped_item.translation = translation + Vector3(0, .1, 0)
	loose_item()



func _on_Hurtbox_area_entered(area: Area) -> void:
	if god_mode:
		return
	if area.name.begins_with("Magic"):
		$HurtParticles.emitting = true
		var knockback_direction = area.global_transform.origin.direction_to(self.global_transform.origin)
		add_acceleration(knockback_acc * knockback_direction * 2.0)
		UI.hit_effect()
		drop_item()
		$HitSound.play()
		$InvincibilityTimer.start(invinc_time * .2)
		$Hurtbox.set_deferred("monitoring", false)
		$Hurtbox.set_deferred("monitorable", false)
		$SlowTween.interpolate_property(self, "FRICTION", 0.5, FRICTION, 3, Tween.TRANS_QUAD, Tween.EASE_OUT)
		$SlowTween.start()
	elif area.name == "Hitbox":
		$HurtParticles.emitting = true
		var knockback_direction = area.global_transform.origin.direction_to(self.global_transform.origin)
		add_acceleration(knockback_acc * knockback_direction)
		UI.hit_effect()
		drop_item()
		$HitSound.play()
		state = State.STUNNED
		$InvincibilityTimer.start(invinc_time)
		$Hurtbox.set_deferred("monitoring", false)
		$Hurtbox.set_deferred("monitorable", false)
		$StunnedTimer.start(stun_time)  # when this timeouts you are not stunned anymore
		# player is immediately stunned but wait a little for the stunnedparticles to show

	#	$StunnedParticles.emitting = true
		yield(get_tree().create_timer(0.5), "timeout")	
		stun_visuals()

export(Color) var stun_color;
func stun_visuals():
	$StunnedParticle/Trail3D.clear_points()
	$StunnedParticle/Trail3D.material_override.albedo_color = stun_color
#	$StunnedParticle/Trail3D.render(true)
	$StunnedParticle/Trail3D.emit = true
	base_translation = $StunnedParticle.transform.origin
	$Tween.interpolate_method(self, "move_along_vortex", 0.0, 1, 0.5)
	$Tween.start()
	#yield(get_tree().create_timer(.08), "timeout")
	#$StunnedParticle.visible = true
	yield($Tween,"tween_all_completed")
#	$StunnedParticle/Trail3D.render(false)
	$StunnedParticle/Trail3D.emit = false
	$Tween.reset_all()
	# start fading out FAST
	var stun_color_blend_out = Color(stun_color)
	stun_color_blend_out.a = 0.0
	$Tween.interpolate_property($StunnedParticle/Trail3D.material_override, "albedo_color", null, stun_color_blend_out, 0.6)
	$Tween.start()
	yield($Tween,"tween_all_completed")
	#$StunnedParticle.visible = false
	$StunnedParticle/Trail3D.clear_points()
	$StunnedParticle.transform.origin = base_translation



var base_translation: Vector3
func move_along_vortex(t: float):
	$StunnedParticle.transform.origin = base_translation + vortex_curve(t)


export var min_height = 0.05
export var max_height = 0.50
export var number_of_swirls = 3
export var max_width = 0.5
func vortex_curve(t: float) -> Vector3:
	var height = max_height * t
	var x = min_height + height * sin(number_of_swirls * t*2*PI)
	var z = min_height + height * cos(number_of_swirls * t*2*PI)
	return Vector3(x, height, z)


func _on_StunnedTimer_timeout() -> void:
	state = State.DEFAULT
	$StunnedParticles.emitting = false


func _on_InvincibilityTimer_timeout() -> void:
	$Hurtbox.set_deferred("monitoring", true)
	$Hurtbox.set_deferred("monitorable", true)

func grab_weapon(type):
	$Weapon.type = type
	$WeaponAnimationPlayer.play("idle")
