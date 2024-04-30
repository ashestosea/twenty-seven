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
	(_debug_grid[index(i,j)].get_node("Sprite") as Sprite2D).modulate = c;
	
func debug_set_tile_color2(indx: int, c: Color):
	(_debug_grid[indx].get_node("Sprite") as Sprite2D).modulate = c;

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
			_grid.append(null);
			var dt = _debug_tile_scene.instantiate();
			dt.position = real_pos(i, j);
			add_child(dt);
			_debug_grid.append(dt);

#region Snap
func snap_tiles():
	_grid.filter(func(tile): return tile != null).map(snap_tile);
	# await get_tree().process_frame;
	# await get_tree().create_timer(0.1).timeout;
	# _game_manager._on_snap_choose_new_substate_requested();

func snap_tile(tile: Tile):
	tile.place();
	tile.enable_collider();
	
	if tile.has_moved():
		_grid[index_vec(tile._grid_pos_cache)] = null;
		debug_set_tile_color(tile._grid_pos_cache.x, tile._grid_pos_cache.y, Color.WHITE);
		tile.snap_to_grid(tile.grid_pos.x, tile.grid_pos.y);
		tile.name = "tile (%s, %s)" % [tile.grid_pos.x, tile.grid_pos.y];
		var i = index_vec(tile.grid_pos);
		# if _grid[i] != null:
		# 	print("match at ", tile.grid_pos);
		# 	tile.set_level(tile.level + 1);
		# 	var old_tile = _grid[i];
		# 	old_tile.free();
		
		_grid[i] = tile;
		debug_set_tile_color2(i, Color.BLUE);
		# print("grid[%s] = %s" % [i, tile.grid_pos]);
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
	for i in GRID_WIDTH:
		for j in GRID_HEIGHT:
			var tile = get_tile(i, j);
			if tile != null:
				var count = get_column_tile_count(i, j);
				var fall_amount = j - count;
				print("%s :: j = %s :: count = %s :: fall_amount = %s" % [tile.grid_pos, j, count, fall_amount]);
				if fall_amount > 0:
					_grid[index(i, j)] = null;
					debug_set_tile_color(i, j, Color.WHITE);
					# tile.grid_pos = Vector2i(i, j - 1);
					fall_tile(tile, fall_amount);
	# if needs_fall():
	# 	fall();

func fall_tile(tile: Tile, fall_amount: int):
	tile.enable_collider();
	var diff = tile.grid_pos.y - fall_amount;
	print("diff = ", diff);
	if diff <= 0:
		fall_amount += diff;
	print("tile %s fall %s spaces" % [tile.grid_pos, fall_amount]);
	tile.fall_to_grid(tile.grid_pos.x, tile.grid_pos.y - fall_amount);
	# tile.snap_to_grid(tile.grid_pos.x, tile.grid_pos.y - fall_amount);
	# position_tile(tile, tile.grid_pos.x, tile.grid_pos.y)
	tile.name = "tile (%s, %s)" % [tile.grid_pos.x, tile.grid_pos.y];
	var i = index_vec(tile.grid_pos); 
	_grid[i] = tile;
	debug_set_tile_color2(i, Color.BROWN);
#endregion

#region Resolve
func needs_resolve():
	return false;
	
func resolve():
	pass
#endregion

#region Add
func add_tiles():
	for i in range(GRID_WIDTH - 1, -1, -1):
		for j in range(GRID_HEIGHT - 1, -1, -1):
			var tile = get_tile(i, j);
			if tile != null:
				_grid[index(i, j)] = get_tile(i, j);
				debug_set_tile_color(i, j, Color.RED);
				# print("adding tile at ", i, j);
				tile.position.y += TILE_WIDTH;
			if j == 0:
				spawn(i, j);

func spawn(i: int, j: int):
	var new_tile = _tile_scene.instantiate() as Tile;
	new_tile.setup(_game_manager, self, i, j, randi_range(1, 4));
	add_child(new_tile);
	get_node(NodePath(new_tile.name)).move_to_front();
	_grid[index(i, j)] = new_tile;
	debug_set_tile_color(i, j, Color.BLACK);
	# print("spawn tile ", new_tile.grid_pos);
#endregion
	
#region Utils
func index(i: int, j: int) -> int:
	return i * GRID_HEIGHT + j;

func index_vec(pos: Vector2i):
	return pos.x * GRID_HEIGHT + pos.y;
	
func get_tile(i: int, j: int) -> Tile:
	var tile_index = index(i, j);
	if tile_index < _grid.size() - 1 and tile_index >= 0:
		return _grid[tile_index] as Tile;
	return null;

func grid_pos(pos: Vector2) -> Vector2i:
	var gp: Vector2i = Vector2i.ZERO;
	gp.x = roundi((pos.x - TILE_WIDTH_HALF) / TILE_WIDTH) - 1;
	gp.y = roundi((GRID_POS_Y_MAX - TILE_WIDTH_HALF - pos.y) / TILE_WIDTH);
	return gp;

func real_pos(i: int, j: int):
	return Vector2(GRID_POS_X_MIN + TILE_WIDTH_HALF + i * TILE_WIDTH, GRID_POS_Y_MAX - TILE_WIDTH_HALF - (j * TILE_WIDTH));

func get_column_top_index(column: int, below: int = GRID_HEIGHT) -> int:
	for j in below:
		var tile = get_tile(column, j);
		if tile == null:
			return j;
	return 0;

func get_column_tile_count(column: int, below: int = GRID_HEIGHT) -> int:
	# print("get column tile count column = %s :: below = %s" % [column, below]);
	var count = 0;
	for j in range(below - 1, -1, -1):
		# print("  ", j);
		if get_tile(column, j) != null:
			count += 1;
			# print("    count = ", count);
	return count;
	
func disable_colliders(tile: Tile):
	for i in GRID_WIDTH:
		for j in GRID_HEIGHT:
			var grid_tile = get_tile(i, j) as Tile;
			if grid_tile == null:
				continue;
			if grid_tile.level == tile.level:
				grid_tile.disable_collider();
	tile.enable_collider();
	
func enable_colliders():
	_grid.filter(func(tile): return tile != null).map(func(tile): tile.enable_collider());
#endregion
