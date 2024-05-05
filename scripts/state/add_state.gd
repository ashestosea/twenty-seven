extends State

var _grid: Grid;

func _enter():
	print("Enter Add");
	await get_tree().create_timer(1).timeout;
	_grid.add_tiles();
	# choose_new_substate_requested.emit();
	
func setup(in_grid: Grid):
	_grid = in_grid;
