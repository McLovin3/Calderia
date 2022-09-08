extends AnimatedSprite
class_name Bobber

signal fish_hooked
signal fish_lost

onready var _caught_timer : Timer = $CaughtTimer

export var bite_rate := 0.15

var hooked = false

func _ready() -> void:
	randomize()

func _on_RandomTimer_timeout():
	if randf() <= bite_rate and not hooked:
		hooked = true
		play("Caught")
		_caught_timer.start()
		emit_signal("fish_hooked")

func _on_CaughtTimer_timeout():
	hooked = false
	play("Bobbing")
	emit_signal("fish_lost")

