class_name Tile extends CharacterBody2D

var level: int;
var grid_pos: Vector2i;

var _game_manager: GameManager;
var _grid: Grid;
var _grid_pos_cache: Vector2i;
var _speed = 50;
var _selected = false;
var _slide = false;
var _slide_target: Vector2;
var _snap = false;
var _snap_target: Vector2;
var _fall = false;
var _fall_target: Vector2;

@onready var _collider = get_node("Collider") as CollisionPolygon2D;

func _physics_process(delta):
	if _slide:
		if position.distance_to(_slide_target) < 0.001:
			_slide = false;
			position = _slide_target;
			grid_pos = _grid.grid_pos(position);
			_grid_pos_cache = grid_pos;
		else:
			velocity = (_slide_target - position) * (1 - exp(-delta * _speed)) / delta;
			move_and_slide();
	if _snap:
		if position.distance_to(_snap_target) < 0.001:
			_snap = false;
			position = _snap_target;
			grid_pos = _grid.grid_pos(position);
			_grid_pos_cache = grid_pos;
			# print("finished snapping to %s, (%s)" % [grid_pos, position]);
		else:
			# var t = (_snap_target - position) * (1 - exp(-delta * _speed)) / delta;
			var t = pow(2, 0.001 * (delta - 0.001));
			# print("snap to %s :: t = %s" % [_snap_target, t]);
			position = lerp(position, _snap_target, t);
	elif _fall:
		if position.distance_to(_fall_target) < 0.001:
			_fall = false;
			position = _fall_target;
			grid_pos = _grid.grid_pos(position);
			_grid_pos_cache = grid_pos;
		else:
			position = lerp(position, _fall_target, pow(2, 1.25 * (delta - 1.25)));

func _on_input_event(_viewport, event, _shape_idx):
	if event.is_action_pressed("ui_touch") and not _selected:
		_game_manager.drag_start(self);
	if event.is_action("ui_touch"):
		_selected = event.is_pressed();

func setup(in_game_manager: GameManager, in_grid: Grid, in_level: int):
	_game_manager = in_game_manager;
	_grid = in_grid;
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

func place():
	_selected = false;
	
func fall_to_real(new_pos: Vector2):
	_slide = false;
	_snap = false;
	_fall = true;
	_fall_target = new_pos;
	
func fall_to_grid(i: int, j: int):
	fall_to_real(_grid.real_pos(i, j));
	
func snap_to_real(new_pos: Vector2):
	_slide = false;
	_fall = false;
	_snap = true;
	_snap_target = new_pos;
	
func snap_to_grid(i: int, j: int):
	snap_to_real(_grid.real_pos(i, j));
	
func slide_to_real(new_pos: Vector2):
	_snap = false;
	_fall = false;
	_slide = true;
	_slide_target = new_pos;
	
func slide_to_grid(i: int, j: int):
	slide_to_real(_grid.real_pos(i, j));
	
func enable_collider():
	_collider.disabled = false;
	
func disable_collider():
	_collider.disabled = true;
