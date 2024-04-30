class_name Grid extends Node2D

var GRID_WIDTH = 7;
var GRID_HEIGHT = 8;
var GRID_POS_X_MIN = 64;
var GRID_POS_Y_MAX = 800;
var TILE_WIDTH = 64;
var TILE_WIDTH_HALF = 32;

var _game_manager: GameManager;
var _grid: Array[Tile];
var _debug_grid: Array[Node2D];
var _bound_top: StaticBody2D;
var _bound_bottom: StaticBody2D;
var _bound_left: StaticBody2D;
var _bound_right: StaticBody2D;

@onready var _tile_scene = load("res://assets/tile.tscn");
@onready var _debug_tile_scene = load("res://assets/tile_debug.tscn");
@onready var _grid_line_horz_scene = load("res://assets/grid_line_horz.tscn");
@onready var _grid_line_vert_scene = load("res://assets/grid_line_vert.tscn");

func debug_set_tile_color(i: int, j: int, c: Color):
	var index = i * GRID_HEIGHT + j;
	(_debug_grid[index].get_node("Sprite") as Sprite2D).modulate = c;
	pass

func _ready():
	add_tiles();
	
	var pos_top = GRID_POS_Y_MAX - (TILE_WIDTH * GRID_HEIGHT);
	var pos_bottom = GRID_POS_Y_MAX;
	var pos_left = GRID_POS_X_MIN;
	var pos_right = GRID_POS_X_MIN + (TILE_WIDTH * GRID_WIDTH);
	
	_bound_top = get_node("BoundTop") as StaticBody2D;
	_bound_bottom = get_node("BoundBottom") as StaticBody2D;
	_bound_left = get_node("BoundLeft") as StaticBody2D;
	_bound_right = get_node("BoundRight") as StaticBody2D;

	_bound_top.position.y = pos_top;
	_bound_bottom.position.y = pos_bottom;
	_bound_left.position.x = pos_left;
	_bound_right.position.x = pos_right;
	
	for i in GRID_HEIGHT - 1:
		var grid_line = _grid_line_horz_scene.instantiate() as Node2D;
		grid_line.position.x = pos_left;
		grid_line.position.y = pos_top + (i + 1) * TILE_WIDTH;
		grid_line.scale.x = pos_right - pos_left;
		add_child(grid_line);
		move_child(grid_line, 0);
	
	for i in GRID_WIDTH - 1:
		var grid_line = _grid_line_vert_scene.instantiate() as Node2D;
		grid_line.position.x = (i + 2) * TILE_WIDTH
		grid_line.position.y = pos_bottom;
		grid_line.scale.y = pos_bottom - pos_top;
		add_child(grid_line);
		move_child(grid_line, 0);
	
	var background = get_node("Background") as Polygon2D;
	move_child(background, 0);
	background.polygon = [\
	 Vector2(pos_left, pos_top),\
	 Vector2(pos_right, pos_top),\
	 Vector2(pos_right, pos_bottom),\
	 Vector2(pos_left, pos_bottom),\
	 ];
	
func setup(in_game_manager: GameManager):
	_game_manager = in_game_manager;
	_debug_tile_scene = load("res://assets/tile_debug.tscn");
	for i in GRID_WIDTH:
		for j in GRID_HEIGHT:
			var dt = _debug_tile_scene.instantiate();
			dt.position = real_pos(i, j);
			add_child(dt);
			_debug_grid.append(dt);

#region Snap
func snap_tiles():
	_grid.map(snap_tile);

func snap_tile(tile: Tile):
	tile.place();
	tile.enable_collider();
	
	if tile.has_moved():
		tile.snap_to_grid(tile.grid_pos.x, tile.grid_pos.y);
		# var i = index_vec(tile.grid_pos);
		# if _grid[i] != null:
		# 	print("match at ", tile.grid_pos);
		# 	tile.set_level(tile.level + 1);
		# 	var old_tile = _grid[i];
		# 	old_tile.free();
#endregion

#region Fall
func needs_fall():
	# for i in GRID_WIDTH:
	# 	var top = get_column_top_index(i);
	# 	for j in range(top - 1, -1, -1):
	# 		if get_tile(i, j) == null:
	# 			return true;
	return false;

func fall():
	for tile in _grid:
		var count = get_column_size_below(tile.grid_pos.x, tile.grid_pos.y);
		var fall_amount = tile.grid_pos.y - count;
		if fall_amount > 0:
			fall_tile(tile, fall_amount)

func fall_tile(tile: Tile, fall_amount: int):
	tile.enable_collider();
	tile.fall_to_grid(tile.grid_pos.x, tile.grid_pos.y - fall_amount);
#endregion

#region Resolve
func needs_resolve():
	return false;
	
func resolve():
	pass
#endregion

#region Add
func add_tiles():
	for i in GRID_WIDTH:
		var tiles = get_tiles_in_column(i);
		if tiles.size() < GRID_HEIGHT:
			for tile in tiles:
				tile.fall_to_grid(i, tile.grid_pos.y + 1);
			spawn(i, 0);

func spawn(i: int, j: int):
	var new_tile = _tile_scene.instantiate() as Tile;
	new_tile.setup(_game_manager, self, i, j, randi_range(1, 4));
	add_child(new_tile);
	get_node(NodePath(new_tile.name)).move_to_front();
	_grid.append(new_tile);
#endregion
	
#region Utils
# func index(i: int, j: int) -> int:
# 	return i * GRID_HEIGHT + j;

# func index_vec(pos: Vector2i):
# 	return pos.x * GRID_HEIGHT + pos.y;
	
# func get_tile(i: int, j: int) -> Tile:
# 	var tile_index = index(i, j);
# 	if tile_index < _grid.size() - 1 and tile_index >= 0:
# 		return _grid[tile_index] as Tile;
# 	return null;
	
func get_tile_with_grid_pos(i: int, j: int) -> Tile:
	var gp = Vector2i(i, j);
	return _grid.filter(func(tile): return tile.grid_pos == gp).front();

func get_tiles_in_column(column: int) -> Array[Tile]:
	var tiles: Array[Tile] = [];
	_grid.filter(func(tile): return tile.grid_pos.x == column).map(func(tile): tiles.append(tile));
	tiles.sort_custom(func(a, b): return a.grid_pos < b.grid_pos);
	return tiles;

func grid_pos(pos: Vector2) -> Vector2i:
	var gp: Vector2i = Vector2i.ZERO;
	gp.x = roundi((pos.x - TILE_WIDTH_HALF) / TILE_WIDTH) - 1;
	gp.y = roundi((GRID_POS_Y_MAX - TILE_WIDTH_HALF - pos.y) / TILE_WIDTH);
	return gp;

func real_pos(i: int, j: int):
	return Vector2(GRID_POS_X_MIN + TILE_WIDTH_HALF + i * TILE_WIDTH, GRID_POS_Y_MAX - TILE_WIDTH_HALF - (j * TILE_WIDTH));

# func get_column_top_index(column: int, below: int = GRID_HEIGHT) -> int:
# 	var tiles = get_tiles_in_column(column);
# 	for j in below:
# 		var tile = tiles[j];
# 		if tile == null:
# 			return j - 1;
# 	return 0;

func get_column_size_below(column: int, below: int = GRID_HEIGHT) -> int:
	var tiles = get_tiles_in_column(column);
	var count = tiles.filter(func(tile): return tile.grid_pos.y < below).size();
	return count;
	
func disable_colliders(tile: Tile):
	_grid.filter(func(t):
			return t.level == tile.level\
			and t != tile)\
		.map(func(t): t.disable_collider());
	tile.enable_collider();
	
func enable_colliders():
	_grid.map(func(tile): tile.enable_collider());
#endregion
