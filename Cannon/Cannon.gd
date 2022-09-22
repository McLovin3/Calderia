extends Node2D
class_name Cannon

onready var _cannon_ball : PackedScene = preload("res://CannonBall/CannonBall.tscn")
onready var _projectile_spawn : Position2D = $ProjectileSpawn
onready var _animated_sprite : AnimatedSprite = $AnimatedSprite

func _ready() -> void:
	_animated_sprite.connect("animation_finished", self, "_animation_finished")

func _unhandled_input(event) -> void:
	if (event.is_action_pressed("right_arrow")):
		_animated_sprite.play("ChargeUp")
	
	elif (event.is_action_released("right_arrow") and not _animated_sprite.playing):
		_animated_sprite.play("Fire")
	
	elif (_animated_sprite.playing):
		_animated_sprite.play("Idle")


func _animation_finished() -> void:
	if (_animated_sprite.animation == "Fire"):
		var instance = _cannon_ball.instance()
		instance.position = _projectile_spawn.global_position
		instance.direction = Vector2(cos(rotation), sin(rotation))
		add_child(instance)
	
	elif (_animated_sprite.animation == "ChargeUp"):
		_animated_sprite.stop()
