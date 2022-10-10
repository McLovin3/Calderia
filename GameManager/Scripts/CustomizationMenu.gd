extends Control
class_name CustomizationMenu

export var tween_duration : float = 0.2
export var tween_final_position : Vector2 = Vector2(75, 0)

var player : PlayerShip

var _cannon : PackedScene = preload("res://Cannon/Cannon.tscn")
onready var _left_button : OptionButton = $LeftItem
onready var _right_button : OptionButton = $RightItem
onready var _left_tween : Tween = $LeftItem/Tween
onready var _right_tween : Tween = $RightItem/Tween
onready var _dialog : ConfirmationDialog = $ConfirmationDialog
onready var _alert_dialog : AcceptDialog = $AlertDialog

var _inventory_open : bool = false
var _tools : Dictionary
var _last_selected_item : Dictionary
var _last_selected_item_name : String
var _is_right : bool
var _last_selected_index : int

func _ready() -> void:
	_dialog.get_close_button().disabled = true
	_dialog.get_close_button().visible = false
	_alert_dialog.get_close_button().disabled = true
	_alert_dialog.get_close_button().visible = false

func _unhandled_key_input(event : InputEventKey) -> void:
	if (event.is_action_pressed("customize") 
		and not _left_tween.is_active() 
		and not _right_tween.is_active()):
		
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
		_left_button, 
		"rect_position", 
		initial_position, 
		final_position, 
		tween_duration)
	_left_tween.start()

func _right_tween_setup(initial_position : Vector2, final_position : Vector2) -> void:
	_right_tween.interpolate_property(
		_right_button, 
		"rect_position", 
		initial_position, 
		final_position, 
		tween_duration)
	_right_tween.start()

func _on_Tween_tween_all_completed():
	if not _inventory_open:
		visible = false

func _on_LeftItem_item_selected(index: int) -> void:
	_tools = GameManager.get_tools()
	if player:
		if index == 0:
			player.clear_left_tool()
		elif index == 1:
			if not _tools.leftTools.cannon.unlocked:
				_left_button.selected = 0
				_dialog.dialog_text = "Acheter pour %s bois et %s pierres?" \
					% [_tools.leftTools.cannon.price.wood, _tools.leftTools.cannon.price.stone]
				_last_selected_item = _tools.leftTools.cannon
				_last_selected_item_name = "cannon"
				_is_right = false
				_last_selected_index = 1
				_dialog.popup()
			else:
				player.set_left_tool(_cannon)

func _on_RightItem_item_selected(index: int) -> void:
	_tools = GameManager.get_tools()
	if player:
		if index == 0:
			player.clear_right_tool()
		elif index == 1:
			if not _tools.rightTools.cannon.unlocked:
				_right_button.selected = 0
				_dialog.dialog_text = "Acheter pour %s bois et %s pierres?" \
					% [_tools.rightTools.cannon.price.wood, _tools.rightTools.cannon.price.stone]
				_last_selected_item = _tools.rightTools.cannon
				_last_selected_item_name = "cannon"
				_last_selected_index = 1
				_is_right = true
				_dialog.popup()
			else:
				player.set_right_tool(_cannon)

func _on_ConfirmationDialog_confirmed()-> void:
	var ressources = GameManager.get_ressources()
	
	if (_last_selected_item.price.wood > ressources.wood
		or _last_selected_item.price.stone > ressources.stone):
		_alert_dialog.popup()
		return
	
	ressources.stone -= _last_selected_item.price.stone
	ressources.wood -= _last_selected_item.price.wood
	GameManager.set_ressources(ressources)
	GameManager.unlock_item(_is_right, _last_selected_item_name)
	_tools = GameManager.get_tools()
	
	if _is_right:
		_on_RightItem_item_selected(_last_selected_index)
		_right_button.selected = _last_selected_index
	
	else:
		_on_LeftItem_item_selected(_last_selected_index)
		_left_button.selected = _last_selected_index
