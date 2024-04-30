extends State

var _grid: Grid;

func _enter():
	print("Enter Snap");
	_grid.enable_colliders();
	_grid.snap_tiles();
	
func setup(in_grid: Grid):
	_grid = in_grid;
