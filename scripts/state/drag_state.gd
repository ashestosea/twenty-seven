extends State

var _grid: Grid;

func _enter():
	print("Enter Drag");

func _update(_delta):
	print("Update Drag");
	if _grid.needs_fall():
		choose_new_substate_requested.emit();
		
func setup(in_grid: Grid):
	_grid = in_grid;
