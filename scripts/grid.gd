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
	_grid.map(func(tile): tile.snap_to_grid());
#endregion

#region Fall
func needs_fall() -> bool:
	for i in GRID_WIDTH:
		var tiles = get_column_tiles_below(i);
		var tiles_mask: Array[int] = [];
		tiles_mask.resize(GRID_HEIGHT);
		tiles_mask.fill(1);

		for tile in tiles:
			tiles_mask[tile.grid_pos.y] = 0;

		for t in tiles.size():
			if (tiles[t].held):
				continue;
			if (tiles[t].grid_pos.y > 0 and tiles[t-1].level == tiles[t].level):
				return true;
			if tiles_mask.slice(0, tiles[t].grid_pos.y).has(1):
				return true;
	return false;

func needs_fall_old():
	print("Needs fall?");
	for i in GRID_WIDTH:
		if _grid[i].held:
			continue;

		var tiles = get_column_tiles_below(i);
		# print(" column count = ", tiles.size());
		# print("  lowest tile y pos = ", tiles.front().grid_pos.y);
		if tiles.front().grid_pos.y > 0:
			# print("   pos is > 0 :: return true" % [tiles.front().grid_pos.y]);
			return true;
		if tiles.size() < 3:
			# print("   tiles size is < 3 :: return false");
			return false;
		for t in range(2, tiles.size()):
			# print("  dist between tile %s and tile %s = %s" % [t, t - 1, tiles[t].grid_pos.y - tiles[t - 1].grid_pos.y])
			if tiles[t].grid_pos.y - tiles[t - 1].grid_pos.y > 1:
				# print("   dist > 1 :: return true");
				return true;
	return false;

func fall():
	print("fall_______________")
	for i in GRID_WIDTH:
		if _grid[i].held:
			print("%s held" % _grid[i].grid_pos);
			continue;

		print("%s fall" % _grid[i].grid_pos);
		var tiles = get_column_tiles_below(i);
		var tiles_mask: Array[int] = [];
		tiles_mask.resize(GRID_HEIGHT);
		tiles_mask.fill(1);

		for t in tiles.size():
			var tile_height = tiles[t].grid_pos.y;
			if (t > 0 and tiles[t-1].level == tiles[t].level):
				tiles_mask[tile_height] = 1;
			else:
				tiles_mask[tile_height] = 0;

		for t in tiles.size():
			var fall_amount = 0;
			for c in range(0, tiles[t].grid_pos.y):
				fall_amount += tiles_mask[c];
			if (tiles[t].grid_pos.y > 0 and tiles[t-1].level == tiles[t].level):
				fall_amount += 1;
			fall_tile(tiles[t], fall_amount);


func fall_old():
	print("fall");
	for tile in _grid:
		var y = 0;
		var tiles = get_column_tiles_below(tile.grid_pos.x, tile.grid_pos.y);
		print("column under %s size = %s" % [tile.grid_pos, tiles.size()]);
		var top_tile = null;
		if tiles.size() != 0:
			top_tile = tiles.back();
		if top_tile != null:
			print("  top tile pos = %s :: level = %s" % [top_tile.grid_pos, top_tile.level]);
			y = top_tile.grid_pos.y;
			if top_tile.level != tile.level:
				y += 1;
			print("  y = ", y);
		var fall_amount = tile.grid_pos.y - y;
		print("   fall amount = ", fall_amount);
		if fall_amount > 0:
			fall_tile(tile, fall_amount)

func fall_tile(tile: Tile, fall_amount: int):
	tile.fall_to_grid(tile.grid_pos.x, tile.grid_pos.y - fall_amount);
#endregion

#region Resolve
# func needs_resolve():
# 	for i in GRID_WIDTH:
# 		var tiles = get_column_tiles_below(i);


func resolve():
	var upgrade_tiles: Array[int] = [];
	var delete_tiles: Array[int] = [];
	for i in _grid.size():
		if delete_tiles.has(i) or upgrade_tiles.has(i):
			continue;
		for j in _grid.size():
			if i != j and _grid[i].grid_pos == _grid[j].grid_pos:
				upgrade_tiles.append(i);
				delete_tiles.append(j);

	delete_tiles.sort_custom(func(a: int, b: int): return a > b);
	for d in delete_tiles:
		_grid[d].queue_free();
		_grid.remove_at(d);
	for u in upgrade_tiles:
		_grid[u].increase_level();
#endregion

#region Add
func add_tiles():
	for i in GRID_WIDTH:
		var tiles = get_column_tiles_below(i);
		if tiles.size() < GRID_HEIGHT:
			for tile in tiles:
				tile.fall_to_grid(i, tile.grid_pos.y + 1, true);
				tile.grid_pos = Vector2i(i, tile.grid_pos.y + 1);
			spawn(i, 0);

func spawn(i: int, j: int):
	var new_tile = _tile_scene.instantiate() as Tile;
	new_tile.setup(_game_manager, self, i, j, randi_range(1, 4));
	add_child(new_tile);
	get_node(NodePath(new_tile.name)).move_to_front();
	_grid.append(new_tile);
#endregion

#region Utils
func get_tile(i: int, j: int) -> Tile:
	var gp = Vector2i(i, j);
	return _grid.filter(func(tile): return tile.grid_pos == gp).front();

func get_column_tiles_below(column: int, below: int = GRID_HEIGHT) -> Array[Tile]:
	var tiles = _grid.filter(func(tile): return tile.grid_pos.x == column and tile.grid_pos.y < below);
	tiles.sort_custom(func(a, b): return a.grid_pos < b.grid_pos);
	return tiles;

func grid_pos(pos: Vector2) -> Vector2i:
	var gp: Vector2i = Vector2i.ZERO;
	gp.x = roundi((pos.x - TILE_WIDTH_HALF) / TILE_WIDTH) - 1;
	gp.y = roundi((GRID_POS_Y_MAX - TILE_WIDTH_HALF - pos.y) / TILE_WIDTH);
	return gp;

func real_pos(i: int, j: int):
	return Vector2(GRID_POS_X_MIN + TILE_WIDTH_HALF + i * TILE_WIDTH, GRID_POS_Y_MAX - TILE_WIDTH_HALF - (j * TILE_WIDTH));

func disable_colliders(tile: Tile):
	_grid.filter(func(t): return t.level == tile.level and t != tile)\
			.map(func(t): t.disable_collider());
	tile.enable_collider();

func enable_colliders():
	_grid.map(func(tile): tile.enable_collider());
#endregion
