@tool
extends Node3D

@export var object_count: int

@export_tool_button("generate polygenes") var _generate_polygenes_tool_button = generate_polygenes
@export_tool_button("mutation_test") var _mutation_test_tool_button = mutation_test

func generate_polygenes():
	print("--------------------")
	for i in range(object_count):
		var dna = DNA.new_random()
		print("stem_color_r: %f" % dna.get_polygene_value_as_float("stem_color_r"))
	print("--------------------")

func mutation_test():
	var dna = DNA.new_random()
	print_rich(dna.genome_a)
	print_rich(dna.genome_b)
	var mutated_dna = DNA.new(dna.genome_a, dna.genome_b)
	mutated_dna.mutate(8)
	
	for i in range(dna.dna_format.genome_byte_count):
		print("byte %d:" % i)
		print("source dna:  %s %s" % [String.num_uint64(dna.genome_a[i],2).lpad(8, "0"), String.num_uint64(dna.genome_b[i],2).lpad(8, "0")])
		print("mutated dna: %s %s" % [String.num_uint64(mutated_dna.genome_a[i],2).lpad(8, "0"), String.num_uint64(mutated_dna.genome_b[i],2).lpad(8, "0")])