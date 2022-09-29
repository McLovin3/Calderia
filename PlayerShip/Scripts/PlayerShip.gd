extends KinematicBody2D
class_name PlayerShip

var _bobber = preload("res://Bobber/Bobber.tscn")
onready var _hit_box : Area2D = $HitBox
onready var _dash_timer : Timer = $DashCooldown

export var max_speed : int = 500
export var acceleration : float = 0.005
export var friction : float = 0.005
export var wall_slow_multiplier : float = 0.1
export var min_fish_speed : int = 100
export var bite_rate : float = 0.15
export var base_hp : int = 100
export var dash_speed : int = 1000
export var dash_time : float = 0.15
export var dash_distance : float = 1000

var _fishing : bool = false
var _velocity : int = 0
var _direction : Vector2 = Vector2.ZERO
var _current_hp : int
var _dashing : bool = false

var _from : Vector2
var _to : Vector2
var _time : float = 0

func _ready() -> void:
	_current_hp = base_hp
	_dash_timer.start()
	GameManager.set_hp(_current_hp, base_hp)

func _unhandled_input(event) -> void:
	#https://godotengine.org/qa/80382/is-it-possible-to-detect-if-mouse-pointer-hovering-over-area
	var space = get_world_2d().direct_space_state
	
	if not space.intersect_point(get_global_mouse_position()):
		if not _fishing and event.is_action_pressed("fish") && _velocity <= min_fish_speed:
			var instance = _bobber.instance()
			get_parent().add_child(instance)
			instance.position = get_parent().get_local_mouse_position()
			instance._bite_rate_per_frame = bite_rate
			instance.connect("child_exiting_tree", self, "_stopped_fishing")
			_fishing = true

func _stopped_fishing(__) -> void:
	_fishing = false

func _physics_process(delta : float) -> void:
	_rotate(delta)
	_calculate_direction()
	_manage_dash(delta)
	var _unused_velocity = move_and_slide(_direction * _velocity)

func _calculate_direction() -> void:
	if not _fishing and Input.is_action_pressed("up"):
		if is_on_ceiling() || is_on_wall() || is_on_floor():
			_velocity = lerp(_velocity, Input.get_action_strength("up") * max_speed * wall_slow_multiplier, acceleration)
		
		else:
			_velocity = lerp(_velocity, Input.get_action_strength("up") * max_speed, acceleration)
	
	else:
		_velocity = lerp(_velocity, 0, friction)
	
	_direction =  Vector2(sin(rotation), -cos(rotation))

func _rotate(delta : float) -> void:
	if not _fishing:
		var percentage_of_max_speed := _velocity as float / max_speed
		rotation = lerp(rotation, 
			Input.get_axis("turn_left", "turn_right") * delta + rotation, 
			percentage_of_max_speed)


func _manage_dash(delta : float) -> void:
	GameManager.set_dash(_dash_timer.wait_time - _dash_timer.time_left, _dash_timer.wait_time)
	
	if (Input.is_action_just_pressed("dash") and _dash_timer.is_stopped()):
		_dashing = true
		_direction = Vector2(
			global_position.direction_to(get_global_mouse_position())).normalized()
		_time = 0
		_from = position
		_to = position + _direction * dash_distance
		_dash_timer.start()
	
	if (_dashing):
		_time += delta
		if (_time >= dash_time):
			_dashing = false
		position = _from.linear_interpolate(_to, _time)
	

func _on_HitBox_area_entered(area : Area2D) -> void:
	if (area.get_parent().get("damage")):
		_current_hp -= area.get_parent().damage
		
		if (_current_hp <= 0):
			queue_free()
		
		else:
			GameManager.set_hp(_current_hp, base_hp)

