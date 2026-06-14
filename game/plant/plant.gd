@tool
extends Node3D
class_name Plant

@export_group("Assets")
@export var branch_scene: PackedScene
@export var fruit_scene: PackedScene

@export_group("Gen Params")
@export var order: int = 5
@export var max_branch_count: int = 100
@export var subbranch_count_distribution: Curve
@export var subbranch_count_order_variation: Curve
@export var subbranch_spread_horizontal: Curve
@export var subbranch_spread_vertical: Curve
@export_range(0.0, 2.0) var subbranch_scale_multiplier := 1.0

@export_range(0.0, 0.1) var fruit_spawn_chance: float = 0.01

@export_group("")
@export_tool_button("Generate") var _generate_button = generate
@export_tool_button("Clear") var _clear_button = clear

var root_branch: Branch = null
var dna: DNA = null

func generate():
	clear()
	if order <= 0:
		return

	var current_branch_count := 1

	var current_order = 0
	root_branch = branch_scene.instantiate()
	add_child(root_branch)
	root_branch.owner = self
	var target_branches: Array[Branch] = [root_branch]

	while(current_order < order):
		var new_target_branches: Array[Branch] = []
		for target_branch in target_branches:
			var subbranch_count = subbranch_count_distribution.sample(randf())
			var order_variation = (int)(subbranch_count_order_variation.sample(current_order) * randf())
			if order_variation > 0:
				print("Order variation: %d" % order_variation)
			for i in range(max(subbranch_count+order_variation, 1)):
				var branch = branch_scene.instantiate()
				target_branch.subbranches.add_child(branch)
				branch.owner = self
				branch.scale = target_branch.scale * subbranch_scale_multiplier
				branch.rotation_degrees = _get_random_rotation()
				new_target_branches.append(branch)
				current_branch_count += 1

				if current_order > 8 and randf() <= fruit_spawn_chance:
					var fruit: Node3D = fruit_scene.instantiate()
					branch.add_child(fruit)
					fruit.owner = self
					fruit.global_basis = fruit.global_basis.orthonormalized().scaled(Vector3.ONE*0.2).rotated(Vector3.UP, PI)
					fruit.global_position -= fruit.global_transform.basis.y*0.13

				if current_branch_count >= max_branch_count:
					print("Final branch count: %d" % current_branch_count)
					return

		current_order += 1
		target_branches = new_target_branches

	print("Final branch count: %d" % current_branch_count)

func clear():
	if root_branch:
		root_branch.queue_free()

func _sample_rotation(curve: Curve):
	return curve.sample(randf()) * (1 if randf() > 0.5 else -1)

func _get_random_rotation():
	return Vector3(_sample_rotation(subbranch_spread_vertical), _sample_rotation(subbranch_spread_horizontal), 0)
