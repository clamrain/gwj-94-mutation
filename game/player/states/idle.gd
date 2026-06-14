extends State

func physics_process(_delta):
	if Input.get_vector("move_left", "move_right", "move_forward", "move_backward"):
		transition("walking")
		return
	
	if Input.is_action_pressed("jump"):
		host.velocity.y = host.jump_up_velocity

	if not host.is_on_floor():
		transition("airborne")
		return

	host.velocity.x = host.momentum.x * host.momentum_scale
	host.velocity.z = host.momentum.z * host.momentum_scale