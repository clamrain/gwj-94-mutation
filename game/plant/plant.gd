@tool
extends Node3D
class_name Plant

@export_group("Assets")
@export var branch_scene: PackedScene
@export var fruit_scene: PackedScene

@export_group("Gen Params")
#@export var order: int = 5
@export var max_branch_count: int = 100
@export var subbranch_count_distribution: Curve
@export var subbranch_count_order_variation: Curve
@export var subbranch_spread_horizontal: Curve
@export var subbranch_spread_vertical: Curve
@export_range(0.0, 2.0) var subbranch_scale_multiplier := 1.0

@export var branch_growing_duration: float = 0.5
@export var fruit_branch_min_order: int = 6
@export var fruit_count: int = 4

@export_group("")
@export_tool_button("Generate") var _generate_button = generate
@export_tool_button("Clear") var _clear_button = clear

@onready var pollination_candidate_area: Area3D = %PollinationCandidateRadius

var root_branch: Branch = null
var branches: Array[Branch] = []
var dna: DNA = null

func new_branch() -> Branch:
	var branch: Branch = branch_scene.instantiate()
	branch.color = Color(
		dna.get_polygene_as_float("stem_color_r"),
		dna.get_polygene_as_float("stem_color_g"),
		dna.get_polygene_as_float("stem_color_b"),
	)
	return branch

func generate():
	clear()
	if Engine.is_editor_hint():
		dna = DNA.new_random()

	var current_branch_count := 1
	var current_order = 0
	root_branch = new_branch()

	root_branch.scale.y = lerp(0.3, 2.0, dna.get_polygene_as_float("stem_length"))
	root_branch.scale.x = lerp(0.3, 2.0, dna.get_polygene_as_float("stem_thickness"))
	root_branch.scale.z = lerp(0.3, 2.0, dna.get_polygene_as_float("stem_thickness"))

	var order = int(lerp(8, 20, dna.get_polygene_as_float("order_count")))

	add_child(root_branch)
	root_branch.owner = self
	branches.append(root_branch)

	var target_branches: Array[Branch] = [root_branch]

	# spawn branches
	while(current_order < order):
		var new_target_branches: Array[Branch] = []
		for target_branch in target_branches:
			var subbranch_count = subbranch_count_distribution.sample(randf())
			var order_variation = (int)(subbranch_count_order_variation.sample(current_order) * randf())
			var final_subbranch_count = int(max(subbranch_count+order_variation, 1))
			for i in range(final_subbranch_count):
				var branch = new_branch()
				target_branch.subbranches.add_child(branch)
				branch.owner = self
				branches.append(branch)
				branch.order = current_order

				branch.rotation_degrees = _get_random_rotation()
				new_target_branches.append(branch)
				current_branch_count += 1

				if current_branch_count >= max_branch_count:
					break

				animate_growth.call(branch, target_branch)

			if current_branch_count >= max_branch_count:
				break


		# wait for growing animations to finish
		await get_tree().create_timer(branch_growing_duration * 1.05).timeout	

		current_order += 1
		target_branches = new_target_branches

		if current_branch_count >= max_branch_count:
			break

	# spawn fruits
	var _branches = branches.duplicate()
	for i in range(fruit_count):
		var branch = null
		while not branch or branch.order < fruit_branch_min_order:
			branch = _branches.pick_random()
		_branches.erase(branch)

		var neighbor_plants = pollination_candidate_area.get_overlapping_areas()
		if neighbor_plants.has($Area3D):
			neighbor_plants.erase($Area3D)
		if not neighbor_plants.is_empty() or Engine.is_editor_hint():
			var genome_a = null
			var genome_b = null
			if Engine.is_editor_hint():
				genome_a = DNA.get_randomized_genome()
				genome_b = DNA.get_randomized_genome()
			else:
				var pollinator_plant: Plant = neighbor_plants.pick_random().get_parent()
				genome_a = dna.get_shuffled_genome()
				genome_b = pollinator_plant.dna.get_shuffled_genome()
			var fruit: Fruit = fruit_scene.instantiate()
			var new_dna = DNA.new(genome_a, genome_b)
			new_dna.mutate(4)
			fruit.dna = new_dna
			branch.add_child(fruit)
			fruit.owner = self
			fruit.global_basis = fruit.global_basis.orthonormalized().scaled(Vector3.ONE*0.5).rotated(Vector3.UP, PI)
			fruit.global_position -= fruit.global_transform.basis.y*0.13

func animate_growth(b, t_b):
	b.scale = Vector3.ONE * 0.1
	var tween = create_tween()
	b.relative_scale = t_b.relative_scale * subbranch_scale_multiplier
	tween.tween_property(b, "scale", t_b.scale, branch_growing_duration)
	await tween.finished

func clear():
	if root_branch:
		root_branch.queue_free()

func _sample_rotation(curve: Curve):
	return curve.sample(randf()) * (1 if randf() > 0.5 else -1)

func _get_random_rotation():
	var vertical_rotation = _sample_rotation(subbranch_spread_vertical)
	vertical_rotation = lerp(vertical_rotation/4.0, vertical_rotation*2, dna.get_polygene_as_float("branch_angle"))
	return Vector3(vertical_rotation, _sample_rotation(subbranch_spread_horizontal), 0)
