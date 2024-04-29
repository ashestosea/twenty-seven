class_name Tile extends CharacterBody2D

var level: int;
var grid_pos: Vector2i;

var _grid_pos_cache: Vector2i;
var _game_manager: GameManager;
var _speed = 50;
var _selected = false;

@onready var _collider = get_node("Collider") as CollisionPolygon2D;

func _physics_process(delta):
	if _selected:
		velocity = (get_viewport().get_mouse_position() - position) * (1 - exp(- delta * _speed)) / delta;
		move_and_slide();
		_game_manager.drag(self);

func _on_input_event(_viewport, event, _shape_idx):
	if event.is_action_pressed("ui_touch") and not _selected:
		_game_manager.drag_start(self);
	if event.is_action("ui_touch"):
		_selected = event.is_pressed();

func setup(in_game_manager: GameManager, in_level: int):
	_game_manager = in_game_manager;
	set_level(in_level);
	
func set_level(in_level: int):
	level = in_level;
	$Label.text = String.num(level);
	var colors = [\
			Color.LIGHT_BLUE,\
			Color.LIGHT_CORAL,\
			Color.LIGHT_GOLDENROD,\
			Color.LIGHT_GRAY,\
			Color.LIGHT_GREEN,\
			Color.LIGHT_PINK,\
			Color.LIGHT_SEA_GREEN,\
			Color.CORNFLOWER_BLUE,\
			Color.FOREST_GREEN,\
			Color.DEEP_SKY_BLUE];
	$Sprite.modulate = colors[level-1];
	
func has_moved():
	return grid_pos != _grid_pos_cache;
	
func set_pos(new_pos: Vector2, new_grid_pos: Vector2i):
	position = new_pos;
	grid_pos = new_grid_pos;
	_grid_pos_cache = new_grid_pos;

func place():
	_selected = false;
	
func enable_collider():
	_collider.disabled = false;
	
func disable_collider():
	_collider.disabled = true;
