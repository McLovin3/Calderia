extends AnimatedSprite
class_name Bobber

var _random_fish : PackedScene = preload("res://RandomFish/RandomFish.tscn") 
onready var _quick_time_event : PackedScene = preload("res://QuickTimeEvent/QuickTimeEvent.tscn")
onready var _caught_timer : Timer = $CaughtTimer

export var base_ressource_amount : int = 25
var _bite_rate_per_frame : float = 0.15
var _fish_size_max_percentage : float = 0.3
var _hooked : bool = false
var _fish_size : float = 0.0

func _ready() -> void:
	while _fish_size == 0.0:
		_fish_size = rand_range(1 - _fish_size_max_percentage, 1 + _fish_size_max_percentage)
	randomize()

func _unhandled_input(event) -> void:
	if _hooked and event.is_action_pressed("fish"):
		var instance = _quick_time_event.instance()
		instance.connect("quick_time_event_succeeded", self, "_fish_caught")
		instance.connect("quick_time_event_failed", self, "_fish_escaped")
		instance.frames_per_second *= _fish_size
		add_child(instance)
	
	elif not _hooked and event.is_action_pressed("fish"):
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
	get_parent().add_child(instance)
	instance.position = position
	if instance.texture.resource_path.find("Wood") != -1:
		GameManager.add_wood(int(base_ressource_amount * _fish_size))
	elif instance.texture.resource_path.find("Stone") != -1:
		GameManager.add_stone(int(base_ressource_amount * _fish_size))
	elif instance.texture.resource_path.find("G") != -1:
		GameManager.add_gunpowder(int(base_ressource_amount * _fish_size))
	queue_free()

func _fish_escaped() -> void:
	queue_free()
