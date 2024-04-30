extends State

var _grid: Grid;

func _enter():
	print("Enter Resolve");
	_grid.resolve();
	choose_new_substate_requested.emit();
	
func setup(in_grid: Grid):
	_grid = in_grid;
