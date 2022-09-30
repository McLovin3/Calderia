extends Camera2D
class_name ZoomingCamera2D

#https://www.gdquest.com/tutorial/godot/2d/camera-zoom/
export var zoom_duration : float = 0.2
export var zoom_out_factor : float = 2

onready var _tween : Tween = $Tween
var _original_zoom : Vector2

func _ready():
	_original_zoom = zoom

func _unhandled_input(event : InputEvent) -> void:
	if (event.is_action_pressed("zoom_out")):
		_set_zoom_level(_original_zoom * zoom_out_factor)
	
	elif (event.is_action_released("zoom_out")):
		_set_zoom_level(_original_zoom)

func _set_zoom_level(final_zoom : Vector2) -> void:
	_tween.interpolate_property(self, "zoom", zoom, final_zoom, zoom_duration)
	_tween.start()
