extends Node2D
class_name CannonBall

onready var _hit_box : Area2D = $Hitbox
onready var _sprite : Sprite = $Sprite
onready var _timer : Timer = $Timer

export var time_to_live : int = 5
export var damage : int = 10
export var rotation_speed : int = 5
export var speed : int = 500

var direction : Vector2 = Vector2.ZERO

func _ready() -> void:
	set_as_toplevel(true)
	
	_hit_box.connect("area_entered", self, "_on_hit")
	
	_timer.connect("timeout", self, "queue_free")
	_timer.wait_time = time_to_live
	_timer.start()

func _physics_process(delta : float) -> void:
	position += direction * delta * speed
	_sprite.rotation += delta * rotation_speed

func _on_hit() -> void:
	queue_free()
