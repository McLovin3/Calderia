extends Node2D
class_name Cannon

onready var _cannon_ball : PackedScene = preload("res://CannonBall/CannonBall.tscn")
onready var _projectile_spawn : Position2D = $ProjectileSpawn
onready var _animated_sprite : AnimatedSprite = $AnimatedSprite

func _unhandled_input(event : InputEvent) -> void:
	if (event.is_action_pressed("shoot")):
		_animated_sprite.play("ChargeUp")
	
	elif (event.is_action_released("shoot") and not _animated_sprite.playing):
		_animated_sprite.play("Fire")
	
	elif (event.is_action_released("shoot") and _animated_sprite.playing):
		_animated_sprite.play("Idle")


func _on_AnimatedSprite_animation_finished():
	if (_animated_sprite.animation == "Fire"):
		var instance = _cannon_ball.instance()
		instance.position = _projectile_spawn.global_position
		instance.direction = Vector2(cos(global_rotation), sin(global_rotation))
		add_child(instance)
	
	elif (_animated_sprite.animation == "ChargeUp"):
		_animated_sprite.stop()
