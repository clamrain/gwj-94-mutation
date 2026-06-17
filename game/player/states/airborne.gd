extends State

func enter():
	host._momentum_retention = 1.0

func exit():
	host._momentum_retention = host.momentum_retention

func physics_process(delta):
	if host.is_on_floor():
		land()
		if Input.is_action_pressed("jump"):
			host.velocity.y = host.jump_up_velocity
			return
		elif Input.get_vector("move_left", "move_right", "move_forward", "move_backward"):
			transition("walking")
			return
		else:
			transition("idle")
			return

	host.velocity.x = host.momentum.x
	host.velocity.z = host.momentum.z
	host.velocity += host.get_gravity() * delta

func land():
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (host.transform.basis as Basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# keep momentum when landing
	var rotated_momentum
	if direction:
		rotated_momentum = host.momentum.rotated(
			host.momentum.cross(direction).normalized(),
			acos(host.momentum.normalized().dot(direction.normalized()))
		)
		host.momentum = rotated_momentum
