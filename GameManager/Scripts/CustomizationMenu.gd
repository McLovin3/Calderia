extends CanvasLayer
class_name CustomizationMenu

export var tween_duration : float = 0.2
export var sail_turn_multiplier_additive : float = 1.5
export var tween_final_position : Vector2 = Vector2(75, 0)

var player : PlayerShip

var _cannon : PackedScene = preload("res://Upgrades/Cannon.tscn")
var _sail : PackedScene = preload("res://Upgrades/Sail.tscn")
onready var _left_button : OptionButton = $LeftItem
onready var _right_button : OptionButton = $RightItem
onready var _left_tween : Tween = $LeftItem/Tween
onready var _right_tween : Tween = $RightItem/Tween
onready var _dialog : ConfirmationDialog = $ConfirmationDialog
onready var _alert_dialog : AcceptDialog = $AlertDialog

var _left_tool : PackedScene
var _right_tool : PackedScene
var _inventory_open : bool = false
var _last_selected_item : Dictionary

func _ready() -> void:
	_dialog.get_close_button().disabled = true
	_dialog.get_close_button().visible = false
	_alert_dialog.get_close_button().disabled = true
	_alert_dialog.get_close_button().visible = false

func _unhandled_key_input(event : InputEventKey) -> void:
	if player:
		if (event.is_action_pressed("customize") 
			and not _left_tween.is_active() 
			and not _right_tween.is_active()):
			
			if not _inventory_open:
				_left_button.visible = true
				_right_button.visible = true
				_left_tween_setup(_left_button.rect_position, _left_button.rect_position - tween_final_position)
				_right_tween_setup(_right_button.rect_position, _right_button.rect_position + tween_final_position)
			
			elif _inventory_open:
				_left_tween_setup(_left_button.rect_position, _left_button.rect_position + tween_final_position)
				_right_tween_setup(_right_button.rect_position, _right_button.rect_position - tween_final_position)
				
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
		_left_button.visible = false
		_right_button.visible = false
	
	player.turn_multiplier = 1
	
	
	if (_right_tool == _sail):
		player.turn_multiplier += sail_turn_multiplier_additive
	
	if (_left_tool == _sail):
		player.turn_multiplier += sail_turn_multiplier_additive

func _select_item(is_right: bool, index: int) -> void:
	var tools = GameManager.get_tools()
	_last_selected_item.is_right = is_right
	_last_selected_item.index = index
	
	if player:
		if index == 0:
			if is_right:
				player.clear_right_tool()
				_right_tool = null
			else:
				player.clear_left_tool()
				_left_tool = null
		elif index == 1:
			if not tools.cannon.unlocked:
				_left_button.selected = 0
				_dialog.dialog_text = "Acheter pour %s bois, %s pierres et %s poudre à canon?" \
					% [tools.cannon.wood, tools.cannon.stone, tools.cannon.gunpowder]
				_last_selected_item.wood = tools.cannon.wood
				_last_selected_item.stone = tools.cannon.stone
				_last_selected_item.gunpowder = tools.cannon.gunpowder
				_last_selected_item.name = "cannon"
				_right_button.selected = 0
				_dialog.popup()
			else:
				if is_right:
					player.set_right_tool(_cannon)
					_right_tool = _cannon
				else:
					player.set_left_tool(_cannon)
					_left_tool = _cannon
		elif index == 2:
			if not tools.sail.unlocked:
				_left_button.selected = 0
				_dialog.dialog_text = "Acheter pour %s bois, %s pierres et %s poudre à canon?" \
					% [tools.sail.wood, tools.sail.stone, tools.sail.gunpowder]
				_last_selected_item.wood = tools.sail.wood
				_last_selected_item.stone = tools.sail.stone
				_last_selected_item.gunpowder = tools.sail.gunpowder
				_last_selected_item.name = "sail"
				_right_button.selected = 0
				_dialog.popup()
			else:
				if is_right:
					player.set_right_tool(_sail)
					_right_tool = _sail
				elif not is_right:
					player.set_left_tool(_sail)
					_left_tool = _sail

func _on_LeftItem_item_selected(index: int) -> void:
	_select_item(false, index)

func _on_RightItem_item_selected(index: int) -> void:
	_select_item(true, index)

func _on_ConfirmationDialog_confirmed()-> void:
	var ressources = GameManager.get_ressources()
	
	if (_last_selected_item.wood > ressources.wood
		or _last_selected_item.stone > ressources.stone
		or _last_selected_item.gunpowder > ressources.gunpowder):
		_alert_dialog.popup()
		return
	
	GameManager.unlock_item(_last_selected_item.name)
	
	if _last_selected_item.is_right:
		_on_RightItem_item_selected(_last_selected_item.index)
		_right_button.selected = _last_selected_item.index
	
	else:
		_on_LeftItem_item_selected(_last_selected_item.index)
		_left_button.selected = _last_selected_item.index
