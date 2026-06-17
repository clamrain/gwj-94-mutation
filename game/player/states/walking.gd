extends State

func physics_process(_delta):
	if not host.is_on_floor():
		transition("airborne")
		return

	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	if input_dir == Vector2.ZERO:
		transition("idle")
		return

	if Input.is_action_pressed("jump"):
		host.velocity.y = host.jump_up_velocity

	var direction := (host.transform.basis as Basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	host.velocity.x = direction.x * host.speed + host.momentum.x * host.momentum_scale
	host.velocity.z = direction.z * host.speed + host.momentum.z * host.momentum_scale
