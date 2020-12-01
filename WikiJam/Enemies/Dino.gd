extends KinematicBody

export(NodePath) var player_path
export(float) var speed

onready var growl_sound = get_node("GrowlSound")
onready var confuse_sound = get_node("ConfuseSound")
onready var see_sound = get_node("SeeSound")

var _current_nav_path: PoolVector3Array
var _player
var _had_path_in_previous_frame = false

onready var _navigation = get_parent()


func _ready():
	_player = get_node(player_path)


func _physics_process(delta: float) -> void:
	# Play growling sound at random interval
	var distance_to_player = (_player.transform.origin - transform.origin).length()
	
	if randi() % 1000 == 1 and not _is_any_sound_playing():
		growl_sound.play()


func _process(delta):
	var to = _navigation.get_closest_point(_player.transform.origin)
	_current_nav_path = _navigation.get_simple_path(transform.origin, to)
	
	var dir: Vector3
	
	if _current_nav_path.size() > 0:
		if not _had_path_in_previous_frame and not _is_any_sound_playing():
			see_sound.play()
		
		var index = 0
		if (_current_nav_path[0] - transform.origin).length() < 0.1: index = 1
		
		dir = (_current_nav_path[index] - transform.origin).normalized()
		
		_had_path_in_previous_frame = true
	else:
		if _had_path_in_previous_frame and not _is_any_sound_playing():
			confuse_sound.play()
		
		dir = (_player.transform.origin - transform.origin).normalized()
		_had_path_in_previous_frame = false
	
	if (dir.x != 0.0 and dir.z != 0.0):
		look_at(transform.origin + Vector3(dir.x, 0.0, dir.z), Vector3.UP)
	
	move_and_slide(dir * speed)


func _is_any_sound_playing():
	return growl_sound.playing or confuse_sound.playing or see_sound.playing
