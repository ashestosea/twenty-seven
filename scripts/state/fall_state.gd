extends State
class_name FallState

var _grid: Grid;

func _enter():
	print("Enter Fall :: ", Time.get_ticks_msec());
	_grid.fall();
	await get_tree().create_timer(1).timeout;
	choose_new_substate_requested.emit();
	
# func _update(_delta):
# 	print("Fall ", _timer_object.time_left);
	
# func _before_exit():
# 	print("Fall ", _timer_object.time_left);
	
func setup(in_grid: Grid):
	_grid = in_grid;
