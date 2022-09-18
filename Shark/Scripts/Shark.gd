extends KinematicBody2D
class_name Shark
#https://www.youtube.com/watch?v=aW4Oa-4dyXA&t=2s&ab_channel=GDQuest

export var path_to_player := NodePath() 
export var speed := 50
export var attack_distance := 500

onready var _navigation_agent := $NavigationAgent2D
onready var _player : PlayerShip = get_node(path_to_player); 
onready var _animated_sprite = $AnimatedSprite

var _velocity := Vector2.ZERO
var _chasing = false

func _ready() -> void:
	randomize()
	_animated_sprite.rotation = rand_range(0, 360)

func _physics_process(delta : float) -> void:
	var direction := global_position.direction_to(_navigation_agent.get_next_location())
	var desired_velocity := direction * speed
	var steering := (desired_velocity - _velocity) * delta
	_velocity += steering
	
	if global_position.distance_to(_player.get_global_position()) < attack_distance:
		_chasing = true
		_animated_sprite.rotation = direction.angle()
		_animated_sprite.play("Emerging")
		_velocity = move_and_slide(_velocity)
		_animated_sprite.rotation = _velocity.angle()
	
	elif _chasing :
		_chasing = false
		_animated_sprite.play("Emerging", true)

func _on_PathFindingTimer_timeout():
	_navigation_agent.set_target_location(_player.global_position)
