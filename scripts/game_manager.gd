class_name GameManager extends Node

var _drag_tile: Tile;

@onready var _grid: Grid = get_node("../Grid");
@onready var _input = get_node("../Input");

func _ready():
	_grid.setup(self);
	_input.setup(self);

func drag_start(tile: Tile):
	_drag_tile = tile;
	_grid.set_colliders_state(tile);

func drag(tile: Tile):
	_grid.adjust_grid_tile_pos(tile);
	
func drop():
	_drag_tile = null;
	_grid.snap_tiles();
	
func add():
	_grid.add();

