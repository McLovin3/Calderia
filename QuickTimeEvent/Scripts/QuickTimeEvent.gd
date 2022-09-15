extends Control
class_name QuickTimeEvent

signal quick_time_event_succeeded
signal quick_time_event_failed


onready var _animated_sprites : AnimatedSprite = $AnimatedSprite
onready var _timer : Timer = $Timer

export var frames_per_second := 25.0

var _animation_name : String

func _ready() -> void:
	# https://godotengine.org/qa/78007/there-way-randomly-select-animation-play-for-animated-sprite
	randomize()
	_get_random_mouse_button()

func _get_random_mouse_button() -> void:
	var animations := _animated_sprites.frames.get_animation_names()
	var animation_id := randi() % animations.size()
	_animation_name = animations[animation_id]
	
	_animated_sprites.frames.set_animation_speed(_animation_name, frames_per_second)
	_timer.set_wait_time(_animated_sprites.frames.get_frame_count(_animation_name) / frames_per_second)
	
	_animated_sprites.play(_animation_name)
	_timer.start()

func _unhandled_input(event) -> void:
	if event is InputEventMouseButton or event is InputEventKey:
		if _animation_name == "LeftClick" and event.is_action_pressed("left_click"):
			emit_signal("quick_time_event_succeeded")
		
		elif _animation_name == "RightClick" and event.is_action_pressed("right_click"):
			emit_signal("quick_time_event_succeeded")
		
		elif _animation_name == "MiddleClick" and event.is_action_pressed("middle_click"):
			emit_signal("quick_time_event_succeeded")
		
		elif event.is_pressed():
			emit_signal("quick_time_event_failed")

func _on_Timer_timeout() -> void:
	emit_signal("quick_time_event_failed")
