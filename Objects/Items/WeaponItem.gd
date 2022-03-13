tool
extends Spatial

signal weapon_grabbed

export(Weapon.TYPE) var type := Weapon.TYPE.Sword setget set_type

func set_type(t):
	type = t
	$Weapon.type = t
	$InteractionObject.interaction_text = "grab the " + str(Weapon.TYPE.keys()[t])

func interact():
	var success = Game.player.grab_weapon($Weapon.type)
	UI.show_attack_tutorial()
	$Weapon.queue_free()
	$InteractionObject.queue_free()
	$AudioStreamPlayer.play()
	emit_signal("weapon_grabbed")

func make_flying():
	$InteractionObject.set_deferred("monitoring", false)
	$InteractionObject.set_deferred("monitorable", false)
	#$StaticBody/CollisionShape.set_deferred("disabled", true)

func burn_effect():
	pass

func _ready():
	set_type(type)


func _on_AudioStreamPlayer_finished():
	queue_free()
