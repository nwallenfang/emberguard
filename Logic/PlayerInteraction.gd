extends Area

var all_areas: Array = []
var player: Spatial
var selected_area : InteractionObject

func _ready():
	player = get_parent() as Spatial

func update_selection():
	all_areas.sort_custom(self, "selection_object_sorter")
	for i in range(all_areas.size()):
		var area = all_areas[i] as InteractionObject
		if area != null:
			area.selected = (i == 0)

func _physics_process(_delta):
	if all_areas.size() > 0:
		update_selection()
		selected_area = all_areas[0]
		if Input.is_action_just_pressed("interact"):
			interact()
	else:
		selected_area = null
		UI.set_interact_text("")

func selection_object_sorter(a, b):
	return player.translation.distance_to(a.get_pos()) < player.translation.distance_to(b.get_pos())

func _on_Interaction_area_entered(area):
	all_areas.append(area)

func _on_Interaction_area_exited(area):
	all_areas.erase(area)
	area.selected = false

func interact():
	selected_area.interact()
