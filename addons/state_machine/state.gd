extends Node
class_name State

var host: Node

var _transition: Callable
func transition(new_state):
	_transition.call(self, new_state)

func enter():
	return

func exit():
	return

func process(_delta):
	return

func physics_process(_delta):
	return

func input_process(_event):
	return