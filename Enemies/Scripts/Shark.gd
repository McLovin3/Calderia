extends KinematicBody2D
class_name Shark

export var path_to_player : NodePath = NodePath() 
export var speed : int = 50
export var attack_distance : int = 500
export var base_hp : int = 30
export var damage : int = 10
export var knockback_distance : int = 200
export var knockback_time : float = 1

onready var _player : PlayerShip = get_node(path_to_player); 
onready var _navigation_agent : NavigationAgent2D = $NavigationAgent2D
onready var _animated_sprite : AnimatedSprite = $AnimatedSprite
onready var _health_bar : ProgressBar = $HealthBar

var _velocity : Vector2 = Vector2.ZERO
var _chasing : bool = false
var _getting_knockbacked : bool = false
var _current_hp : int
var _time : float = 0
var _from : Vector2 = Vector2.ZERO
var _to : Vector2 = Vector2.ZERO

func _ready() -> void:
	randomize()
	_current_hp = base_hp
	_animated_sprite.rotation = rand_range(0, 360)

func _physics_process(delta : float) -> void:
	if (is_instance_valid(_player)):
		var direction := global_position.direction_to(_navigation_agent.get_next_location())
		var desired_velocity := direction * speed
		var steering := (desired_velocity - _velocity) * delta
		_velocity += steering
		
		if (_getting_knockbacked):
			_time += delta
			if (_time >= knockback_time):
				_getting_knockbacked = false
			position = _from.linear_interpolate(_to, _time)
		
		elif global_position.distance_to(_player.get_global_position()) < attack_distance:
			_chasing = true
			_animated_sprite.rotation = direction.angle()
			_animated_sprite.play("Emerging")
			_velocity = move_and_slide(_velocity)
			_animated_sprite.rotation = _velocity.angle()
		
		elif _chasing :
			_chasing = false
			_animated_sprite.play("Emerging", true)

func _on_PathFindingTimer_timeout() -> void:
	if (is_instance_valid(_player)):
		_navigation_agent.set_target_location(_player.global_position)

func _on_Hitbox_area_entered(area: Area2D) -> void:
	if (area.get_parent().get("damage")):
		_current_hp -= area.get_parent().damage
		
		if (_current_hp <= 0):
			queue_free()
		
		else:
			_health_bar.visible = true
			_health_bar.value = (_current_hp * _health_bar.max_value) / base_hp 
	
	else:
		_getting_knockbacked = true
		_time = 0
		_from = position
		_to = position - knockback_distance * Vector2(
			global_position.direction_to(area.global_position)).normalized()
