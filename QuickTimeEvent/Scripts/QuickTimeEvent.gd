extends Control
class_name QuickTimeEvent

signal fish_caught
signal fish_escaped

onready var _animated_sprites : AnimatedSprite = $AnimatedSprite
onready var _timer : Timer = $Timer

export var frames_per_second := 25.0

var _animation_name : String

func _ready() -> void:
	# https://godotengine.org/qa/78007/there-way-randomly-select-animation-play-for-animated-sprite
	randomize()
	_get_random_animation()

func _get_random_animation() -> void:
	var animations := _animated_sprites.frames.get_animation_names()
	var animation_id := randi() % animations.size()
	_animation_name = animations[animation_id]
	
	_animated_sprites.frames.set_animation_speed(_animation_name, frames_per_second)
	_timer.set_wait_time(_animated_sprites.frames.get_frame_count(_animation_name) / frames_per_second)
	
	_animated_sprites.play(_animation_name)
	_timer.start()

func _unhandled_input(event) -> void:
	if event is InputEventMouseButton or event is InputEventKey:
		if _animation_name == "LeftClick" and event.is_action("left_click"):
			print("Fish Caught")
		
		elif _animation_name == "RightClick" and event.is_action("right_click"):
			emit_signal("fish_caught")
		
		elif _animation_name == "MiddleClick" and event.is_action("middle_click"):
			emit_signal("fish_caught")
		
		else:
			emit_signal("fish_escaped")
			queue_free()

func _on_Timer_timeout() -> void:
	emit_signal("fish_escaped")
	queue_free()
