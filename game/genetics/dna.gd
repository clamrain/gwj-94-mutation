extends RefCounted
class_name DNA

const dna_format: DNAFormat = preload("res://game/genetics/default_dna_format.tres")

var genome_a: PackedByteArray
var genome_b: PackedByteArray

func _init(parent_genome_a: PackedByteArray, parent_genome_b: PackedByteArray) -> void:
	assert(parent_genome_a.size() == dna_format.genome_byte_count)
	assert(parent_genome_b.size() == dna_format.genome_byte_count)
	genome_a = PackedByteArray(parent_genome_a)
	genome_b = PackedByteArray(parent_genome_b)

static func new_random() -> DNA:
	return DNA.new(DNA.get_randomized_genome(), DNA.get_randomized_genome())

func mutate(bitflip_count: int):
	var positions = []
	for i in range(bitflip_count):
		var coordinates = []
		while true:
			coordinates = [randi() % 2, randi() % dna_format.genome_byte_count, randi() % 8]
			if not positions.has(coordinates.hash()):
				positions.append(coordinates.hash())
				break

		var genome = genome_a if coordinates[0] == 1 else genome_b
		genome[coordinates[1]] ^= (1 << (coordinates[2]))

func get_shuffled_genome() -> PackedByteArray:
	var new_genome = PackedByteArray()
	new_genome.resize(dna_format.genome_byte_count)
	var source_genome = genome_a
	for i in range(dna_format.genome_byte_count):
		if i % dna_format.chromosome_byte_count == 0:
			source_genome = genome_a if randf()>0.5 else genome_b		
		new_genome[i] = source_genome[i]
	return new_genome

static func get_randomized_genome() -> PackedByteArray:
	var new_genome = PackedByteArray()
	new_genome.resize(dna_format.genome_byte_count)
	for i in range(dna_format.genome_byte_count):
		new_genome[i] = randi() % 256
	return new_genome

func get_gene(gene_id: String) -> Gene:
	var gene: Gene = null
	for g: Variant in dna_format.gene_list:
		if g.id == gene_id:
			gene = g
	assert(gene != null, "Gene with id '%s' does not exist." % gene_id)
	return gene

func get_polygene_as_float(gene_id: String) -> float:
	var gene: Gene = get_gene(gene_id)
	assert(gene.type == "poly")	
	var result = 0
	for i in range(gene.start_position, gene.end_position):
		result += evaulate_locus(i)
	return inverse_lerp(0, (gene.end_position - gene.start_position)*2, result)

func get_gene_value(gene_id: String) -> int:
	var gene: Gene = get_gene(gene_id)
	var result = -1
	if gene:
		match(gene.type):
			"single":
				assert(gene.start_position == gene.end_position)
				result = evaulate_locus(gene.start_position)
			"poly":
				assert(gene.start_position < gene.end_position)
				result = 0
				for i in range(gene.start_position, gene.end_position):
					result += evaulate_locus(i)
			_:
				assert(false)

	return result

func evaulate_locus(position: int) -> int:
	var chromosome_a = genome_a[position / 8]
	var chromosome_b = genome_b[position / 8]
	var bit_position = position % 8
	return (int)((chromosome_a >> bit_position) & 1) + (int)((chromosome_b >> bit_position) & 1)	
