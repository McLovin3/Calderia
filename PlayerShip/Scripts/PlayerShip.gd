extends KinematicBody2D
class_name PlayerShip

export var max_speed := 20000
export var turning_speed := 1
export var acceleration := 0.001
export var friction := 0.005
export var wall_slow_multiplier = 0.1

func _physics_process(delta : float) -> void:
	_rotate(delta)
	var _unused_velocity = move_and_slide(_get_direction(delta))

var _velocity := 0
func _get_direction(delta : float) -> Vector2:
	if Input.is_action_pressed("up"):
		if is_on_ceiling() || is_on_wall() || is_on_floor():
			_velocity = lerp(_velocity, Input.get_action_strength("up") * max_speed * wall_slow_multiplier, acceleration)
		
		else:
			_velocity = lerp(_velocity, Input.get_action_strength("up") * max_speed, acceleration)
	
	else:
		_velocity = lerp(_velocity, 0, friction)
	
	var direction_player_is_facing =  Vector2(sin(rotation), -cos(rotation))
	return direction_player_is_facing * _velocity * delta


func _rotate(delta : float) -> void:
	var percentage_of_max_speed := _velocity as float / max_speed
	rotation = lerp(rotation, Input.get_axis("turn_left", "turn_right") * delta + rotation, percentage_of_max_speed)
