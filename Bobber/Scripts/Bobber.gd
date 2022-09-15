extends AnimatedSprite
class_name Bobber

signal stone_collected
signal wood_collected

var _random_fish := preload("res://RandomFish/RandomFish.tscn") 
onready var _quick_time_event := preload("res://QuickTimeEvent/QuickTimeEvent.tscn")
onready var _caught_timer : Timer = $CaughtTimer

export var _bite_rate_per_frame := 0.15
var _fish_size_max_percentage := 0.5
var _hooked := false

func _ready() -> void:
	randomize()

func _unhandled_input(event) -> void:
	if _hooked and event.is_action_pressed("left_click"):
		var instance = _quick_time_event.instance()
		instance.connect("fish_caught", self, "_fish_caught")
		instance.connect("fish_escaped", self, "_fish_escaped")
		instance.frames_per_second *= rand_range(1 - _fish_size_max_percentage, 1 + _fish_size_max_percentage)
		add_child(instance)
	
	elif not _hooked and event.is_action_pressed("left_click"):
		print("Cancelled")
		queue_free()

func _on_RandomTimer_timeout() -> void:
	if randf() <= _bite_rate_per_frame and not _hooked:
		_hooked = true
		play("Caught")
		_caught_timer.start()

func _on_CaughtTimer_timeout() -> void:
	_hooked = false
	play("Bobbing")

func _fish_caught() -> void:
	var instance : RandomFish = _random_fish.instance()
	instance.position = position
	get_parent().add_child(instance)
	queue_free()

func _fish_escaped() -> void:
	queue_free()
