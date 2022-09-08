extends KinematicBody2D
class_name PlayerShip

var _bobber = preload("res://Bobber/Bobber.tscn")

export var max_speed := 20000
export var turning_speed := 1
export var acceleration := 0.001
export var friction := 0.005
export var wall_slow_multiplier := 0.1
export var min_fish_speed := 2000
export var bite_rate := 0.15

var _fishing = false
var _velocity := 0

func _unhandled_input(event) -> void:
	if not _fishing and event.is_action_pressed("left_click") && _velocity <= min_fish_speed:
		var instance = _bobber.instance()
		get_parent().add_child(instance)
		instance.position = get_parent().get_local_mouse_position()
		instance.set_bite_rate(bite_rate)
		get_tree().root.print_tree_pretty()
		instance.connect("child_exiting_tree", self, "_stopped_fishing")
		_fishing = true

func _stopped_fishing(joe):
	_fishing = false

func _physics_process(delta : float) -> void:
	_rotate(delta)
	var _unused_velocity = move_and_slide(_get_direction(delta))

func _get_direction(delta : float) -> Vector2:
	if not _fishing and Input.is_action_pressed("up"):
		if is_on_ceiling() || is_on_wall() || is_on_floor():
			_velocity = lerp(_velocity, Input.get_action_strength("up") * max_speed * wall_slow_multiplier, acceleration)
		
		else:
			_velocity = lerp(_velocity, Input.get_action_strength("up") * max_speed, acceleration)
	
	else:
		_velocity = lerp(_velocity, 0, friction)
	
	var direction_player_is_facing =  Vector2(sin(rotation), -cos(rotation))
	return direction_player_is_facing * _velocity * delta

func _rotate(delta : float) -> void:
	if not _fishing:
		var percentage_of_max_speed := _velocity as float / max_speed
		rotation = lerp(rotation, Input.get_axis("turn_left", "turn_right") * delta + rotation, percentage_of_max_speed)
