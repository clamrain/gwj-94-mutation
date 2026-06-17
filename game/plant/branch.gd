@tool
extends Node3D
class_name Branch

@onready var subbranches: Node3D = %Subbranches
@onready var mesh_instance: MeshInstance3D:
	get():
		if not mesh_instance:
			mesh_instance = $MeshInstance3D
		return mesh_instance

@export_color_no_alpha var color: Color = Color.WHITE:
	set(_color):
		color = _color
		if $StemMesh and $ThornsMesh:
			$StemMesh.get_active_material(0).albedo_color = color
			$ThornsMesh.get_active_material(0).albedo_color = color

var order = -1
var relative_scale = 1