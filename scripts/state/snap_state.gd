extends State
class_name SnapState

var _grid: Grid;

func _enter():
	print("Enter Snap");
	_grid.enable_colliders();
	_grid.snap_tiles();
	
func _update(_delta):
	print("Snap ", _timer_object.time_left);
	
func _before_exit():
	print("Snap ", _timer_object.time_left);
	
func setup(in_grid: Grid):
	_grid = in_grid;
