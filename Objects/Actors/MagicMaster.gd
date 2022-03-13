extends KinematicBody


export var health := 12

func magic_blast():
	pass

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
	$Hurtbox.set_deferred("monitoring", false)
	$Hurtbox.set_deferred("monitorable", false)
	get_parent().master_defeated()
	$magician_master.visible = false
	$DyingSound.play()
	$DeathParticles.emitting = true
	yield(get_tree().create_timer(3),"timeout")
	queue_free()
