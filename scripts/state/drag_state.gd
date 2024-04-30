extends State

var _grid: Grid;
var _drag_tile: Tile;

func _enter():
	print("Enter Drag");

func _update(_delta):
	print("Update Drag");
	_grid.adjust_grid_tile_pos(_drag_tile);
	if _grid.needs_fall():
		choose_new_substate_requested.emit();
		
func setup(in_grid: Grid):
	_grid = in_grid;

func set_tile(in_tile: Tile):
	_drag_tile = in_tile;
