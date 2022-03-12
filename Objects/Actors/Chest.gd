tool
extends Spatial

export var open_percent := 0.0 setget set_open_percent

var we_dont_want_buggy_and_retarded_ass_error_messages_godot_thanks_for_nothing := true

func set_open_percent(p):
	open_percent = p
	$Top.rotation_degrees.z = p * 180
	if we_dont_want_buggy_and_retarded_ass_error_messages_godot_thanks_for_nothing:
		we_dont_want_buggy_and_retarded_ass_error_messages_godot_thanks_for_nothing = false
		return
	if is_instance_valid($GodRay):
		if p < .005:
			$GodRay.visible = false
		else:
			$GodRay.visible = true
