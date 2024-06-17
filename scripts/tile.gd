class_name Tile extends CharacterBody2D

var level: int;
var grid_pos: Vector2i;
var held: bool;

var _game_manager: GameManager;
var _grid: Grid;
var _grid_pos_cache: Vector2i;
var _speed = 50;
var _slide = false;
var _slide_target: Vector2;
var _snap = false;
var _snap_target: Vector2;
var _fall = false;
var _fall_target: Vector2;
var _set_cache: bool;

@onready var _collider = get_node("Collider") as CollisionPolygon2D;

func _physics_process(delta):
	if _slide:
		if position.distance_to(_slide_target) < 0.01:
			_finalize_pos(_slide_target, _set_cache);
			_set_cache = false;
		else:
			velocity = (_slide_target - position) * (1 - exp(-delta * _speed)) / delta;
			move_and_slide();
			grid_pos = _grid.grid_pos(position);
			set_tile_name(grid_pos);
	if _snap:
		if position.distance_to(_snap_target) < 0.01:
			_finalize_pos(_snap_target, _set_cache);
			_set_cache = false;
		else:
			# var t = (_snap_target - position) * (1 - exp(-delta * _speed)) / delta;
			var t = pow(2, 0.001 * (delta - 0.001));
			# print("snap to %s :: t = %s" % [_snap_target, t]);
			position = lerp(position, _snap_target, t);
			grid_pos = _grid.grid_pos(position);
			set_tile_name(grid_pos);
	elif _fall:
		if position.distance_to(_fall_target) < 0.01:
			_finalize_pos(_fall_target, _set_cache);
			_set_cache = false;
		else:
			position = lerp(position, _fall_target, pow(2, 1.25 * (delta - 1.25)));
			grid_pos = _grid.grid_pos(position);
			set_tile_name(grid_pos);

func _on_input_event(_viewport, event, _shape_idx):
	if event.is_action_pressed("ui_touch"):
		_game_manager.drag_start(self);

func setup(in_game_manager: GameManager, in_grid: Grid, i: int, j: int, in_level: int):
	_game_manager = in_game_manager;
	_grid = in_grid;
	grid_pos = Vector2i(i, j);
	_grid_pos_cache = grid_pos;
	position = _grid.real_pos(i, j);
	set_tile_name(grid_pos);
	set_level(in_level);

func set_tile_name(in_grid_pos: Vector2i):
	name = "Tile (%s, %s)" % [in_grid_pos.x, in_grid_pos.y];

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
	$Sprite.modulate = colors[(level-1) % colors.size()];

func increase_level():
	set_level(level + 1);

func has_moved():
	return grid_pos != _grid_pos_cache;

func fall_to_real(new_pos: Vector2, set_cache: bool = true):
	_slide = false;
	_snap = false;
	_fall = true;
	_fall_target = new_pos;
	_set_cache = set_cache;

func fall_to_grid(i: int = -1, j: int = -1, set_cache: bool = true):
	if i == -1 or j == -1:
		fall_to_real(_grid.real_pos(grid_pos.x, grid_pos.y), set_cache);
	else:
		fall_to_real(_grid.real_pos(i, j), set_cache);

func snap_to_real(new_pos: Vector2, set_cache: bool = true):
	_slide = false;
	_fall = false;
	_snap = true;
	_snap_target = new_pos;
	_set_cache = set_cache;

func snap_to_grid(i: int = -1, j: int = -1, set_cache: bool = true):
	if i == -1 or j == -1:
		snap_to_real(_grid.real_pos(grid_pos.x, grid_pos.y), set_cache);
	else:
		snap_to_real(_grid.real_pos(i, j), set_cache);

func slide_to_real(new_pos: Vector2, set_cache: bool = true):
	_snap = false;
	_fall = false;
	_slide = true;
	_slide_target = new_pos;
	_set_cache = set_cache;

func slide_to_grid(i: int = -1, j: int = -1, set_cache: bool = true):
	if i == -1 or j == -1:
		slide_to_real(_grid.real_pos(grid_pos.x, grid_pos.y), set_cache);
	else:
		slide_to_real(_grid.real_pos(i, j), set_cache);

func enable_collider():
	_collider.disabled = false;

func disable_collider():
	_collider.disabled = true;

func _finalize_pos(new_pos: Vector2, set_cache: bool = true):
	_fall = false;
	_fall_target = Vector2.ZERO;
	_snap = false;
	_snap_target = Vector2.ZERO;
	_slide = false;
	_slide_target = Vector2.ZERO;
	position = new_pos;
	grid_pos = _grid.grid_pos(position);
	set_tile_name(grid_pos);
	if set_cache:
		_grid_pos_cache = grid_pos;
