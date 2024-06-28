class_name GameManager extends State

enum GameMode {
	TORTOISE,
	HARE
}

var _game_mode: GameMode;
var _drag_tile: Tile;
var _has_added: bool;
var _current_matches: int;
var _request_pause: bool;

@onready var _state_idle: State = get_node("Idle");
@onready var _state_pause: State = get_node("Pause");
@onready var _state_drag: State = get_node("Drag");
@onready var _state_snap: State = get_node("Snap");
@onready var _state_fall: State = get_node("Fall");
@onready var _state_resolve: State = get_node("Resolve");
@onready var _state_add: State = get_node("Add");

@onready var _grid: Grid = get_node("../Grid");
@onready var _input = get_node("../Input");

func _ready():
	_grid.setup(self);
	_input.setup(self);
	_state_drag.setup(_grid);
	_state_snap.setup(_grid);
	_state_fall.setup(_grid);
	_state_resolve.setup(_grid);
	_state_add.setup(_grid);

	_grid.match_made.connect(_increment_current_matches);

	_game_mode = GameMode.TORTOISE;

	status = Status.ACTIVE;
	change_state_node(_state_idle);

func _process(_delta):
	if _request_pause:
		pass

# Idle
func _on_idle_choose_new_substate_requested():
	# change_state_node(_state_drag);
	pass;

# Pause
func _on_pause_choose_new_substate_requested():
	change_state_node(_state_idle);

# Drag
func _on_drag_choose_new_substate_requested():
	if _grid.needs_fall():
		change_state_node(_state_fall);

# Snap
func _on_snap_choose_new_substate_requested():
	change_state_node(_state_fall);

# Fall
func _on_fall_choose_new_substate_requested():
	change_state_node(_state_resolve);

	# if _grid.needs_resolve():
	# 	change_state_node(_state_resolve);
	# elif _drag_tile != null:
	# 	change_state_node(_state_drag);
	# else:
	# 	change_state_node(_state_idle);

# Resolve
func _on_resolve_choose_new_substate_requested():
	var img = get_viewport().get_texture().get_image();
	var img_name = ProjectSettings.globalize_path("user://%s.png" % [Time.get_datetime_string_from_system()])
	print(img_name)
	img.save_png(img_name);
	if _grid.needs_fall():
		change_state_node(_state_fall);
	elif _needs_add():
		_has_added = true;
		change_state_node(_state_add);
	elif _drag_tile != null:
		change_state_node(_state_drag);
	else:
		change_state_node(_state_idle);

# Add
func _on_add_choose_new_substate_requested():
	var img = get_viewport().get_texture().get_image();
	var img_name = ProjectSettings.globalize_path("user://%s.png" % [Time.get_datetime_string_from_system()])
	img.save_png(img_name);
	#var proc = OS.create_process(, [img_name]);
	#print("viewnior proc = %s" % [proc])
	change_state_node(_state_resolve);

func drag_start(tile: Tile):
	if get_active_substate() != _state_idle:
		return;

	_current_matches = 0;
	_has_added = false;
	_drag_tile = tile;
	_drag_tile.held = true;
	_input.select_tile(tile);
	_grid.disable_colliders(tile);
	change_state_node(_state_drag);

func drop_held_tile():
	if _drag_tile != null:
		_drag_tile.held = false;
		_drag_tile = null;
		change_state_node(_state_snap);
		_input.drop_held_tile();


func _increment_current_matches():
	_current_matches += 1;

var add_debug = false;

func _needs_add() -> bool:
	match _game_mode:
		GameMode.TORTOISE:
			# If tile moved without a match
			return _current_matches == 0 and !_has_added;
		GameMode.HARE:
			# If timer is out or no matches available
			add_debug = !add_debug;
			return add_debug;
		_:
			return false;
