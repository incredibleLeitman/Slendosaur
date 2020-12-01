extends KinematicBody

# export variables
export(NodePath) var body_nodepath
export(NodePath) var camera_nodepath
export(NodePath) var animation_nodepath
export(NodePath) var ui_nodepath
export(NodePath) var interact_area_nodepath

# const
const GRAVITY = -24.8
const JUMP_SPEED = 8
const MOVE_SPEED = 8
const SPRINT_SPEED = 12
const ACCEL = 15.0
const MAX_SLOPE_ANGLE = 40
const MOUSE_SENSITIVITY = 0.05
const MAX_MOUSE_SPEED = 25
const INTERACT_DISTANCE = 4
const SPRINT_DEC = 40
const SPRINT_ACC = 20

# private members
var _body: Spatial
var _camera: Camera
var _animation: AnimationPlayer
var _interface: Control
var _sprintometer: ProgressBar
var _interact_area: Area
var _dir = Vector3()
var _vel = Vector3()
var _is_sprinting
var _sprintVal: float = 100


func _ready():
	# Assign child node variables
	_body = get_node(body_nodepath) as Spatial
	assert(null != _body)
	
	_camera = get_node(camera_nodepath) as Camera
	assert(null != _camera)
	
	_animation = get_node(animation_nodepath) as AnimationPlayer
	assert(null != _animation)
	
	_interface = get_node(ui_nodepath) as Control
	assert(null != _interface)
	
	_sprintometer = _interface.get_node("ProgressBar")
	assert(null != _sprintometer)
	
	_interact_area = get_node(interact_area_nodepath) as Area
	assert(null != _interact_area)
	
	_interact_area.connect("area_entered", self, "_on_interact_entered")
	
	# Setup mouse look
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _physics_process(delta):
	_process_input()
	_process_movement(delta)
	#Logger.info("sprintVal: " + String(_sprintVal))


func _process(delta):
	_process_animations()
	if _is_sprinting and _sprintVal > 0:
		_sprintVal -= SPRINT_DEC * delta
	elif _sprintVal < 100:
		_sprintVal += SPRINT_ACC * delta


func _process_input():
	#exit
	if Input.is_action_pressed("ui_cancel"):
		_interface.gameOver()

	# Walking
	var input_movement_vector = Vector2()
	if Input.is_action_pressed("move_fwrd"):
		input_movement_vector.y += 1
	if Input.is_action_pressed("move_back"):
		input_movement_vector.y -= 1
	if Input.is_action_pressed("move_left"):
		input_movement_vector.x -= 1
	if Input.is_action_pressed("move_right"):
		input_movement_vector.x += 1

	# look around with controller
	var look = Vector2()
	look.x = -Input.get_action_strength("cam_move_left") + Input.get_action_strength("cam_move_right")
	look.y = +Input.get_action_strength("cam_move_down") - Input.get_action_strength("cam_move_up")
	#Logger.info("look at: " + String(look))
	_camera.rotate_x(deg2rad(look.y * -1))
	self.rotate_y(deg2rad(look.x * -1))
	
	# Prevent player from doing a purzelbaum
	_camera.rotation_degrees.x = clamp(_camera.rotation_degrees.x, -70, 70)

	# look around with mouse
	_dir = Vector3()
	var camera_transform = _camera.get_global_transform()
	_dir += -camera_transform.basis.z * input_movement_vector.y
	_dir += camera_transform.basis.x * input_movement_vector.x
	
	# jumping
	if Input.is_action_just_pressed("move_jump") and is_on_floor():
		_vel.y = JUMP_SPEED

	# sprinting
	_is_sprinting = Input.is_action_pressed("move_sprint") and _sprintVal > 0


func _process_movement(delta):
	_vel.y += delta * GRAVITY

	# set movement speed
	var target = _dir * (SPRINT_SPEED if _is_sprinting else MOVE_SPEED)

	var hvel = _vel
	hvel = hvel.linear_interpolate(target, ACCEL * delta)
	_vel.x = hvel.x
	_vel.z = hvel.z
	_vel = move_and_slide(_vel, Vector3(0, 1, 0), 0.05, 4, deg2rad(MAX_SLOPE_ANGLE))


func _process_animations():
	_animation.playback_speed = _vel.length() / MOVE_SPEED
	
	_sprintometer.value = _sprintVal


func _on_interact_entered(area: Area):
	if area.is_in_group("Crystal"):
		area.get_parent().queue_free()  # Assuming crystal area is always parent of crystal root
		_interface.increaseScore()
	elif area.is_in_group("Dino"):
		_interface.gameOver()


func _input(event):
	# capture mouse movement
	if event is InputEventMouseMotion:
		_camera.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY * -1))
		self.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))
		
		# Prevent player from doing a purzelbaum
		_camera.rotation_degrees.x = clamp(_camera.rotation_degrees.x, -70, 70)
