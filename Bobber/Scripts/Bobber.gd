extends AnimatedSprite
class_name Bobber

signal fish_hooked
signal fish_lost

onready var _caught_timer : Timer = $CaughtTimer

var _bite_rate
var hooked = false

func _init(bite_rate : float) -> void:
	_bite_rate = bite_rate

func _ready() -> void:
	randomize()

func _on_RandomTimer_timeout():
	if randf() <= _bite_rate and not hooked:
		hooked = true
		play("Caught")
		_caught_timer.start()
		emit_signal("fish_hooked")

func _on_CaughtTimer_timeout():
	hooked = false
	play("Bobbing")
	emit_signal("fish_lost")

