extends State
class_name SnapState

var _grid: Grid;

func _enter():
	print("Enter Snap :: ", Time.get_ticks_msec());
	_grid.enable_colliders();
	_grid.snap_tiles();
	await get_tree().create_timer(0.01).timeout;
	choose_new_substate_requested.emit();
	
func _update(_delta):
	if _timer_object:
		print("Snap ", _timer_object.time_left);
	
func _before_exit():
	if _timer_object:
		print("Snap ", _timer_object.time_left);
	
func setup(in_grid: Grid):
	_grid = in_grid;
