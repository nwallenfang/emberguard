extends KinematicBody


export var health := 12

export var blast_scale_start := 2.0
export var blast_scale_end := 30.0
export var trigger_dist := 5.0
export var blast_speed := 1.5

var blast_ready := true


func _on_Hurtbox_area_entered(area):
	if area.name.begins_with("EnemyDetect"):
		return
	if area.name.begins_with("Scare"):
		return
	if area.name.begins_with("Player"):
		health -= 1
		$GettingHitSound.play()
		$HitParticles.emitting = true
		$HitParticles.restart()
#	$Hurtbox.set_deferred("monitoring", false)
#	$Hurtbox.set_deferred("monitorable", false)
#	$InvincTimer.start()
	#yield(get_tree().create_timer(.5), "timeout")
	if health == 0:
		die()

func _on_InvincTimer_timeout():
	$Hurtbox.set_deferred("monitoring", true)
	$Hurtbox.set_deferred("monitorable", true)
	
func die():
	$MagicBlast.queue_free()
	$MagicLoad.emitting = false
	$Hurtbox.set_deferred("monitoring", false)
	$Hurtbox.set_deferred("monitorable", false)
	get_parent().master_defeated()
	$magician_master.visible = false
	$DyingSound.play()
	$DeathParticles.emitting = true
	yield(get_tree().create_timer(3),"timeout")
	queue_free()

func activate_blast():
	blast_ready = false
	$MagicLoad.emitting = true
	$Buildup.play()
	yield(get_tree().create_timer(2.5), "timeout")
	if health == 0:
		return
	$Explosion.play()
	$MagicLoad.emitting = false
	$MagicBlast.visible = true
	$MagicBlast.set_alpha(1.0)
	$MagicBlast.set_hitbox(true)
	$BlastTween.interpolate_property($MagicBlast, "alpha", 1.0, 0.0, blast_speed,Tween.TRANS_QUART,Tween.EASE_IN)
	$BlastTween.interpolate_property($MagicBlast, "scale", Vector3(blast_scale_start, blast_scale_start, blast_scale_start), Vector3(blast_scale_end, blast_scale_end, blast_scale_end), blast_speed)
	$BlastTween.start()
	yield($BlastTween,"tween_all_completed")
	if health == 0:
		return
	$MagicBlast.set_hitbox(false)
	$MagicBlast.visible = false
	$MagicBlast.scale = Vector3(blast_scale_start, blast_scale_start, blast_scale_start)
	$Cooldown.start()

func _on_SlowProcess_timeout():
	if Game.minions_activated:
		if blast_ready:
			var dist := Game.player.global_transform.origin.distance_to(global_transform.origin)
			if dist <= trigger_dist:
				activate_blast()

func _on_Cooldown_timeout():
	blast_ready = true
