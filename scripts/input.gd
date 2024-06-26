extends Node2D

var _game_manager: GameManager;
var _tile: Tile;
var _dragging: bool;
# var _speed = 50;

func _physics_process(_delta):
	if _tile != null and Input.is_action_pressed("ui_touch"):
		_tile.slide_to_real(get_viewport().get_mouse_position(), false);

	if _dragging and not Input.is_action_pressed("ui_touch"):
		drop_held_tile();
		_game_manager.drop_held_tile();

	if Input.is_action_just_pressed("ui_touch"):
		_dragging = true;

func setup(in_game_manager: GameManager):
	_game_manager = in_game_manager;

func select_tile(in_tile: Tile):
	_tile = in_tile;


func drop_held_tile():
	# Don't move GameManager.drop_held_tile call into here or we'll get an infinite loop
	_dragging = false;
	_tile = null;
