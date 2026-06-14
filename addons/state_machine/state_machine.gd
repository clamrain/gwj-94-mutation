extends Node
class_name StateMachine

@export var initial_state: State

signal state_changed(current_state)

var states = {}
var current_state: State = null

func _ready():
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child._transition = transition
			child.host = get_parent()

	await get_parent().ready
	if initial_state:
		initial_state.enter()
		current_state = initial_state

func _process(delta):
	if current_state:
		current_state.process(delta)

func _physics_process(delta):
	if current_state:
		current_state.physics_process(delta)

func _input(event):
	if current_state:
		current_state.input_process(event)

func transition(old_state, new_state_str):
	if old_state != current_state:
		return

	var new_state = states.get(new_state_str.to_lower())
	if not new_state:
		return

	if current_state:
		current_state.exit()

	new_state.enter()
	current_state = new_state
	state_changed.emit(current_state)