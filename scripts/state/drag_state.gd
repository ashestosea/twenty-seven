extends State

var _grid: Grid;

func _enter():
	print("Enter Drag :: ", Time.get_ticks_msec());

func _update(_delta):
	print("Update Drag");
	# Game Manager checks if the Grid needs to fall so we can emit this constantly
	choose_new_substate_requested.emit();

func setup(in_grid: Grid):
	_grid = in_grid;
