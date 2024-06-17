extends State

var _grid: Grid;

func _enter():
	print("Enter Add :: ", Time.get_ticks_msec());
	# await get_tree().create_timer(1).timeout;
	_grid.add_tiles();
	await get_tree().create_timer(1).timeout;
	choose_new_substate_requested.emit();
	
func setup(in_grid: Grid):
	_grid = in_grid;
