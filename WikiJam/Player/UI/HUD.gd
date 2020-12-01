extends Control

export(NodePath) var popup_nodepath
export(NodePath) var gameover_sound_path
export(NodePath) var collect_sound_path
export(NodePath) var container_path

var _popup: Popup
var _gameover_sound: AudioStreamPlayer
var _collect_sound: AudioStreamPlayer
var _collectibles: GridContainer

var _itemWidth = 50;
var _score: int = 0
var _init: bool = false
var _texCrystal = preload("res://Images/crystal-unlit.png")
var _texCrystalLit = preload("res://Images/crystal.png")


func _ready():
	_popup = get_node(popup_nodepath) as Popup
	assert(null != _popup)
	
	_gameover_sound = get_node(gameover_sound_path) as AudioStreamPlayer
	assert(null != _gameover_sound)
	
	_collect_sound = get_node(collect_sound_path) as AudioStreamPlayer
	assert(null != _collect_sound)
	
	_collectibles = get_node(container_path) as GridContainer
	assert(null != _collectibles)


func _process(_delta):
	if _init == false:
		_init = true
		
		# TODO: handle with signals
		var count = Collector.getCount()
		_itemWidth = int(get_viewport_rect().size.x / (count + 1))
		_collectibles.columns = count
		
		for i in count:
			var rect = _createTexture(_texCrystal)
			_collectibles.add_child(rect)


func _createTexture(texture):
	var rect = TextureRect.new()
	rect.texture = texture
	rect.expand = true
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	rect.rect_min_size = Vector2(_itemWidth, _itemWidth)
	return rect


func increaseScore():
	_score += 1
	Logger.info(String(_score) + " of " + String(Collector.getCount()) + " possible points")
	
	_collect_sound.play()
	
	var rect = _createTexture(_texCrystalLit)
	_collectibles.add_child_below_node(_collectibles.get_child(0), rect)
	_collectibles.remove_child(_collectibles.get_child(0 if _score == 1 else _score))
	
	if (_score >= (Collector.getCount())):
		success()


func gameOver():
	Logger.info("YOU FAILED!")
	_gameover_sound.play()
	_endGame(false)


func success():
	Logger.info("YOU WON!")
	_endGame(true)


func _endGame (value):
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	Collector.Clear()
	
	_popup.get_node("CenterContainer/Container/LabelWon").visible = value
	_popup.get_node("CenterContainer/Container/LabelFail").visible = !value
	
	_popup.get_node("PanelWon").visible = value
	_popup.get_node("PanelFail").visible = !value
	_popup.show()


func _on_Button_pressed():
	get_tree().reload_current_scene()
