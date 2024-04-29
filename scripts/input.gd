extends Node2D

var _game_manager: GameManager;
var _dragging: bool;

func _physics_process(_delta):
	if _dragging and not Input.is_action_pressed("ui_touch"):
		_dragging = false;
		_game_manager.drop();
		
	if Input.is_action_just_pressed("ui_touch"):
		_dragging = true;

func setup(in_game_manager: GameManager):
	_game_manager = in_game_manager;
