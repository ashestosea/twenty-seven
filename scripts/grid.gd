class_name Grid extends Node2D

var GRID_WIDTH = 7;
var GRID_HEIGHT = 8;
var GRID_POS_X_MIN = 64;
var GRID_POS_Y_MAX = 800;
var TILE_WIDTH = 64;
var TILE_WIDTH_HALF = 32;

var _game_manager: GameManager;
var _grid: Array[Tile];
var _bound_top: StaticBody2D;
var _bound_bottom: StaticBody2D;
var _bound_left: StaticBody2D;
var _bound_right: StaticBody2D;

@onready var _tile_scene = load("res://assets/tile.tscn");
@onready var _grid_line_horz_scene = load("res://assets/grid_line_horz.tscn");
@onready var _grid_line_vert_scene = load("res://assets/grid_line_vert.tscn");

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
	
	for i in GRID_WIDTH * GRID_HEIGHT:
		_grid.append(null);
	
func add_tiles():
	for i in range(GRID_WIDTH - 1, -1, -1):
		for j in range(GRID_HEIGHT - 1, -1, -1):
			var tile = get_tile(i, j);
			if tile != null:
				_grid.insert(index(i, j), tile);
				tile.position.y += TILE_WIDTH;
			if j == 0:
				spawn(i, j);
	
func index(i: int, j: int) -> int:
	return i * GRID_HEIGHT + j;
	
func get_tile(i: int, j: int) -> Tile:
	var tile_index = index(i, j);
	if tile_index < _grid.size() - 1 and tile_index >= 0:
		return _grid[tile_index] as Tile;
	return null;
	
func adjust_grid_tile_pos(tile: Tile):
	var gp = grid_pos(tile.position);
	tile.grid_pos = gp;
	
func snap_tiles():
	_grid.filter(func(tile): return tile != null).map(place_tile);

func place_tile(tile: Tile):
	tile.place();
	tile.enable_collider();
	if tile.has_moved():
		position_tile(tile, tile.grid_pos.x, tile.grid_pos.y)
		tile.name = "tile (%s, %s)" % [tile.grid_pos.x, tile.grid_pos.y];
		var i = index(tile.grid_pos.x, tile.grid_pos.y);
		if _grid[i] != null:
			tile.set_level(tile.level + 1);
			_grid[i].free();
			
		_grid[i] = tile;

func spawn(i: int, j: int):
	var newTile = _tile_scene.instantiate() as Tile;
	newTile.name = "tile (%s, %s)" % [i, j];
	newTile.setup(_game_manager, randi_range(1, 4));
	position_tile(newTile, i, j);
	add_child(newTile);
	get_node(NodePath(newTile.name)).move_to_front();
	_grid[index(i, j)] = newTile;
	
func grid_pos(pos: Vector2) -> Vector2i:
	var gp: Vector2i = Vector2i.ZERO;
	gp.x = roundi((pos.x - TILE_WIDTH_HALF) / TILE_WIDTH) - 1;
	gp.y = roundi((GRID_POS_Y_MAX - TILE_WIDTH_HALF - pos.y) / TILE_WIDTH);
	return gp;
	
func position_tile(tile: Tile, i: int, j: int):
	tile.set_pos(Vector2(GRID_POS_X_MIN + TILE_WIDTH_HALF + i * TILE_WIDTH, GRID_POS_Y_MAX - TILE_WIDTH_HALF - (j * TILE_WIDTH)), Vector2i(i, j));
	
func set_colliders_state(tile: Tile):
	for i in GRID_WIDTH:
		for j in GRID_HEIGHT:
			var grid_tile = get_tile(i, j) as Tile;
			if grid_tile == null:
				continue;
			if grid_tile.level == tile.level:
				grid_tile.disable_collider();
	tile.enable_collider();
