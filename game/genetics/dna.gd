extends RefCounted
class_name DNA

const dna_format: DNAFormat = preload("res://game/genetics/default_dna_format.tres")

var genome_a: PackedByteArray
var genome_b: PackedByteArray

func _init(parent_genome_a: PackedByteArray, parent_genome_b: PackedByteArray) -> void:
	assert(parent_genome_a.size() == dna_format.genome_size)
	assert(parent_genome_b.size() == dna_format.genome_size)
	genome_a = PackedByteArray(parent_genome_a)
	genome_b = PackedByteArray(parent_genome_b)

func get_shuffled_genome() -> PackedByteArray:
	var new_genome = PackedByteArray()
	new_genome.resize(dna_format.genome_size)
	var target_genome = genome_a if randf()>0.5 else genome_b
	for i in range(dna_format.genome_size):
		new_genome[i] = target_genome[i]
		if i % dna_format.chromosome_size == 0:
			target_genome = genome_a if randf()>0.5 else genome_b
	return new_genome

static func get_randomized_genome() -> PackedByteArray:
	var new_genome = PackedByteArray()
	new_genome.resize(dna_format.genome_size)
	for i in range(dna_format.genome_size):
		new_genome[i] = randi() % 256
	return new_genome