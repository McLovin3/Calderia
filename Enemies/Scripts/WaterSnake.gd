extends KinematicBody2D
class_name WaterSnake

export var path_to_player : NodePath = NodePath() 
export var speed : int = 50
export var attack_distance : int = 600
export var base_hp : int = 20
export var shoot_distance : int = 400

onready var _water_ball : PackedScene = preload("res://Projectiles/WaterBall.tscn")
onready var _player : PlayerShip = get_node(path_to_player); 
onready var _navigation_agent : NavigationAgent2D = $NavigationAgent2D
onready var _animated_sprite : AnimatedSprite = $AnimatedSprite
onready var _health_bar : ProgressBar = $HealthBar
onready var _projectile_spawn : Position2D = $AnimatedSprite/ProjectileSpawn

var _velocity : Vector2 = Vector2.ZERO
var _current_hp : int
var _distance_to_player : float

func _ready() -> void:
	randomize()
	_current_hp = base_hp
	_animated_sprite.rotation = rand_range(0, 360)

func _physics_process(delta : float) -> void:
	_distance_to_player = global_position.distance_to(_player.get_global_position())
	
	if (_distance_to_player < attack_distance):
		var direction : Vector2 = global_position.direction_to(_navigation_agent.get_next_location())
		var desired_velocity : Vector2 = direction * speed
		var steering : Vector2 = (desired_velocity - _velocity) * delta
		_velocity += steering
		
		_animated_sprite.rotation = direction.angle()
		
		if (_distance_to_player > shoot_distance):
			_velocity = move_and_slide(_velocity)

func _on_PathFindingTimer_timeout() -> void:
	if (_player):
		_navigation_agent.set_target_location(_player.global_position)

func _on_Hitbox_area_entered(area: Area2D) -> void:
	if (area.get_parent().get("damage")):
		_current_hp -= area.get_parent().damage
		
		if (_current_hp <= 0):
			queue_free()
		
		else:
			_health_bar.visible = true
			_health_bar.value = (_current_hp * _health_bar.max_value) / base_hp 

func _on_ShootTimer_timeout():
	if (_distance_to_player < attack_distance):
		var instance : Projectile  = _water_ball.instance()
		instance.position = _projectile_spawn.global_position
		instance.direction = Vector2(
			cos(_projectile_spawn.global_rotation), sin(_projectile_spawn.global_rotation))
		instance.rotation = _projectile_spawn.global_rotation
		add_child(instance)
