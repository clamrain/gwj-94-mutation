@tool
extends Node3D
class_name Branch

@onready var subbranches: Node3D = $Subbranches
@onready var mesh_instance: MeshInstance3D:
	get():
		if not mesh_instance:
			mesh_instance = $MeshInstance3D
		return mesh_instance


@export_range(0.0, 1.0) var color_stage: float = 0.0:
	set(value):
		color_stage = value