extends Node2D
class_name Projectile

onready var _sprite : Sprite = $Sprite

export var damage : int = 10
export var rotation_speed : int = 5
export var speed : int = 500

var direction : Vector2 = Vector2.ZERO

func _ready() -> void:
	set_as_toplevel(true)

func _physics_process(delta : float) -> void:
	position += direction * delta * speed
	_sprite.rotation += delta * rotation_speed

func _on_TTL_timeout() -> void:
	queue_free()

func _on_Hitbox_area_entered(_area: Area2D) -> void:
	queue_free()

func get_damage() -> int:
	return damage
