extends Control

export var tween_duration : float = 0.2
export var tween_final_position : Vector2 = Vector2(75, 0)

onready var _left_panel : OptionButton = $LeftItem
onready var _right_panel : OptionButton = $RightItem
onready var _left_tween : Tween = $LeftItem/Tween
onready var _right_tween : Tween = $RightItem/Tween

var _inventory_open : bool = false

func _unhandled_key_input(event : InputEventKey) -> void:
	if event.is_action_pressed("customize") and not _left_tween.is_active() and not _right_tween.is_active():
		
		if not _inventory_open:
			visible = true
			_left_tween_setup(Vector2.ZERO, -tween_final_position)
			_right_tween_setup(Vector2.ZERO, tween_final_position)
		
		elif _inventory_open:
			_left_tween_setup(-tween_final_position, Vector2.ZERO)
			_right_tween_setup(tween_final_position, Vector2.ZERO)
			
		get_tree().paused = !get_tree().paused
		_inventory_open = !_inventory_open

func _left_tween_setup(initial_position : Vector2, final_position : Vector2) -> void:
	_left_tween.interpolate_property(
		_left_panel, 
		"rect_position", 
		initial_position, 
		final_position, 
		tween_duration)
	_left_tween.start()

func _right_tween_setup(initial_position : Vector2, final_position : Vector2) -> void:
	_right_tween.interpolate_property(
		_right_panel, 
		"rect_position", 
		initial_position, 
		final_position, 
		tween_duration)
	_right_tween.start()

func _on_Tween_tween_all_completed():
	if not _inventory_open:
		visible = false


func _on_LeftItem_item_selected(index):
	pass # Replace with function body.


func _on_RightItem_item_selected(index):
	pass # Replace with function body.
