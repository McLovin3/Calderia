extends AnimatedSprite
class_name Bobber

onready var _quick_time_event = preload("res://QuickTimeEvent/QuickTimeEvent.tscn")
onready var _caught_timer : Timer = $CaughtTimer

var _bite_rate := 0.15
var _hooked = false

func set_bite_rate(bite_rate : float) -> void:
	_bite_rate = bite_rate

func _ready() -> void:
	randomize()

func _unhandled_input(event):
	if _hooked and event.is_action_pressed("left_click"):
		var instance = _quick_time_event.instance()
		instance.connect("fish_caught", self, "_fish_caught")
		instance.connect("fish_escaped", self, "_fish_escaped")
		add_child(instance)
	
	elif not _hooked and event.is_action_pressed("left_click"):
		print("Cancelled")
		queue_free()

func _on_RandomTimer_timeout():
	if randf() <= _bite_rate and not _hooked:
		_hooked = true
		play("Caught")
		_caught_timer.start()

func _on_CaughtTimer_timeout():
	_hooked = false
	play("Bobbing")

func _fish_caught():
	print("Caught!")
	queue_free()

func _fish_escaped():
	print("Escaped!")
	queue_free()
