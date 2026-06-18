extends CharacterBody3D
class_name Player

@export var fruit_scene: PackedScene
@export var plant_scene: PackedScene
@export var shovel_scene: PackedScene

@export var speed: float = 5.0
@export_range(0.0, 1.0) var momentum_scale: float = 0.1
@export_range(0.0, 1.0) var momentum_retention: float = 0.5
@export var jump_up_velocity: float = 4.5
@export var jump_speed: float = 4.5

@export_range(0.0, 1.0) var mouse_sensitivity = 0.2
@export_range(0.0, 1.0) var fov_switch_duration: float = 0.2
@export_range(0.0, 1.0) var fov_switch_strength: float = 0.25

@onready var _momentum_retention = momentum_retention
@onready var camera: Camera3D = %Camera3D
@onready var raycast: RayCast3D = %RayCast3D
@onready var hand_inventory: HandInventory = %HandInventory
@onready var plant_hologram: Node3D = %PlantHologram

var _mouse_position = Vector2(0.0, 0.0)
var _total_pitch = 0.0

var momentum = Vector3.ZERO
var targeted_item = null

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	hand_inventory.item_list.append(shovel_scene.instantiate())
	hand_inventory.item_list.append(fruit_scene.instantiate())
	hand_inventory.item_list.append(fruit_scene.instantiate())
	hand_inventory.item_list.append(fruit_scene.instantiate())
	hand_inventory.item_list.append(fruit_scene.instantiate())
	hand_inventory.init_item()

func _input(event):
	if event is InputEventMouseMotion:
		_mouse_position = event.relative

		if raycast.is_colliding() and raycast.get_collider().is_in_group("farmland") and hand_inventory.get_held_item() is Fruit:
			plant_hologram.global_position = raycast.get_collision_point()
			plant_hologram.visible = true
		elif plant_hologram.visible:
			plant_hologram.visible = false

		if raycast.is_colliding() and raycast.get_collider().is_in_group("item_area"):
			if targeted_item and raycast.get_collider() != targeted_item:
				targeted_item.find_child("InteractionOutline").visible = false
				targeted_item = null
			if not targeted_item:
				targeted_item = raycast.get_collider()
				targeted_item.find_child("InteractionOutline").visible = true
		elif targeted_item:
			targeted_item.find_child("InteractionOutline").visible = false
			targeted_item = null

	if event.is_action_released("interact") and raycast.is_colliding():
		raycast_interact()

func _process(_delta):
	_update_rotation()

var _last_velocity := velocity
var _last_global_position := Vector3()
func _physics_process(_delta: float) -> void:
	momentum = momentum * _momentum_retention + velocity * (1.0 - _momentum_retention)
	move_and_slide()
	_update_fov()
	rotate_y(deg_to_rad(-_yaw_delta))
	_yaw_delta = 0.0
	_last_velocity = velocity
	_last_global_position = global_position

@export var fov = 0
func _update_fov():
	camera.fov = fov + momentum.length() * fov_switch_strength * 8.0

var _yaw_delta := 0.0
func _update_rotation():
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		_mouse_position *= mouse_sensitivity
		var yaw = _mouse_position.x
		var pitch = _mouse_position.y
		_mouse_position = Vector2(0, 0)

		# Prevents looking up/down too far
		pitch = clamp(pitch, -90 - _total_pitch, 90 - _total_pitch)
		_total_pitch += pitch
		_yaw_delta += yaw

		camera.rotate_object_local(Vector3(1,0,0), deg_to_rad(-pitch))

func raycast_interact():
	var collider: Node3D = raycast.get_collider()

	if collider.is_in_group("plant_area") and hand_inventory.get_held_item() is Shovel:
		var plant: Plant = collider.get_parent()
		plant.frozen = true
		plant.get_parent().remove_child(plant)
		plant.position = Vector3(0,0.15,0)
		plant.rotate_x(PI*0.75)
		# plant.transform = Transform3D.IDENTITY

		hand_inventory.item_list.append(plant)
		hand_inventory.init_item()

	if collider.is_in_group("farmland"):
		var item = hand_inventory.get_held_item()
		if item is Fruit:
			plant_fruit(item)
			plant_hologram.visible = false
		elif item is Plant:
			hand_inventory.erase_item(item)
			item.get_parent().remove_child(item)
			collider.add_child(item)
			item.owner = collider
			item.transform = Transform3D.IDENTITY
			item.global_position = raycast.get_collision_point()
			item.frozen = false

	if collider.is_in_group("item_area"):
		var item = collider.get_parent()
		item.get_parent().remove_child(item)
		if item is Fruit:
			item.origin_plant.fruit_count -= 1
		item.transform = Transform3D.IDENTITY
		hand_inventory.item_list.append(item)
		hand_inventory.init_item()

func plant_fruit(fruit: Fruit):
	var plant: Plant = plant_scene.instantiate()
	plant.dna = fruit.dna
	
	var collider = raycast.get_collider()
	collider.add_child(plant)
	plant.global_position = raycast.get_collision_point()
	plant.generate()

	hand_inventory.erase_item(fruit)
	fruit.queue_free()
