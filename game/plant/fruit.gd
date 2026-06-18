@tool
extends Node3D
class_name Fruit

var origin_plant: Plant = null
var dna: DNA:
	set(_dna):
		dna = _dna
		color = Color(
			_dna.get_polygene_as_float("stem_color_r"),
			_dna.get_polygene_as_float("stem_color_g"),
			_dna.get_polygene_as_float("stem_color_b"),
		)

@export_color_no_alpha var color: Color = Color.WHITE:
	set(_color):
		color = _color
		if get_node_or_null("%LeafMesh") and get_node_or_null("%CoreMesh"):
			%LeafMesh.get_active_material(0).albedo_color = color
			%CoreMesh.get_active_material(0).albedo_color = color
			%CoreMesh.get_active_material(0).albedo_color

func _ready():
	if not dna:
		dna = DNA.new(DNA.get_randomized_genome(), DNA.get_randomized_genome())