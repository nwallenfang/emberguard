extends Area
class_name InteractionObject

export var outline_color := Color.whitesmoke
export var outline_size := 0.2
export var interaction_text := "interact"

var selected := false setget set_selected
var parent : Spatial
var materials = []

const OUTLINE_MATERIAL = preload("res://Assets/Materials/OutlineShaderMaterial.tres")

func _enter_tree() -> void:
	# prefetch
	# works on node names
	pass

func get_pos():
	return parent.translation

func set_own_and_children_materials_to_outline(n: Node):
	if n.name == "Sword":
		pass
	if n is MeshInstance:
		n = n as MeshInstance
		var mat = n.get_surface_material(0)
		if mat == null:
			mat = n.mesh.get("surface_1/material")
		if mat == null:
			mat = n.mesh.get("material")
		if mat != null:
			var surface_mat = mat.duplicate(true)
			n.material_override = surface_mat
			n.material_override.next_pass = OUTLINE_MATERIAL
			n.material_override.next_pass.set_shader_param("outline_width", outline_size)
			n.material_override.next_pass.set_shader_param("outline_color", outline_color)
	for c in n.get_children():
		set_own_and_children_materials_to_outline(c)

func reset_own_and_children_materials(n: Node):
	if n is MeshInstance:
		n = n as MeshInstance
		n.material_override = null
	for c in n.get_children():
		reset_own_and_children_materials(c)

func _ready():
	parent = get_parent()

func set_selected(value):
	selected = value
	if selected:
		set_own_and_children_materials_to_outline(parent)
		UI.set_interact_text(interaction_text)
	else:
		reset_own_and_children_materials(parent)

func interact():
	parent.interact()
