extends Camera

var velocity: float = 8.0
var angular_velocity: float = 50.0
var transitioning := false


# this function is called by the Tween
var start_transform: Transform
var target_transform: Transform
func interpolate_transform(weight: float):
#	var pre_time = OS.get_ticks_msec()
	self.global_transform = start_transform.interpolate_with(target_transform, weight)
#	var time = OS.get_ticks_msec()
#	print(time - pre_time)
#	if (time - last_time > 100):
#		print(weight)
#	last_time = time


func move_to_transform_and_fov(target_transform_arg: Transform, target_fov: float, _duration: float):
	# maybe these two methods can be combined / are interchangable with the new
	# transform.interpolate_with call
	target_transform = target_transform_arg
	# back up current transform as starting point for interpolation
	start_transform = Transform(global_transform)#Transform(transform)
	
	distance = start_transform.origin.distance_to(target_transform_arg.origin)
	duration = distance / velocity
	if _duration != 0.0:
		duration = _duration
	
	time = 0.0
	move = true
#	$Tween.reset_all()  
#	$Tween.playback_process_mode = Tween.TWEEN_PROCESS_PHYSICS
	#$Tween.interpolate_method(self, "interpolate_transform", 0.0, 1.0, duration, Tween.TRANS_LINEAR)
#	$Tween.interpolate_property(self, "fov", self.fov, target_fov, duration)
	#$Tween.start()

var move = false
var distance
var duration
var time
var render = false
func _process(delta):
	render = not render
	if not render:
		return
	if move:
		var pre_time = OS.get_ticks_msec()
		time += delta * 2
		interpolate_transform(time / duration)
		if time / duration >= 1.0:
			move = false
		var after_time = OS.get_ticks_msec()
		print(str(delta) + " -> " + str(after_time - pre_time))

var last_time = 0

func move_to_transform(target_transform_arg, duration = 0.0):
	move_to_transform_and_fov(target_transform_arg, self.fov, duration)

	
