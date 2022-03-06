extends InteractionObject
class_name FireInteractionObject


func set_selected(value):
	selected = (value and Game.player.item_holded_count > 0)
	if selected:
		set_own_and_children_materials_to_outline(parent)
		UI.set_interact_text(interaction_text)
	else:
		reset_own_and_children_materials(parent)
