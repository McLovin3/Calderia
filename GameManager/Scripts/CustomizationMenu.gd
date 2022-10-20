extends CanvasLayer
class_name CustomizationMenu

export var tween_duration : float = 0.2
export var sail_speed_additive : float = 100
export var paddle_turn_additive : float = 1
export var armor_damage_negation : float = 0.25
export var tween_final_position : Vector2 = Vector2(75, 0)

var player : PlayerShip

var _cannon : PackedScene = preload("res://Upgrades/Cannon.tscn")
var _sail : PackedScene = preload("res://Upgrades/Sail.tscn")
var _paddle : PackedScene = preload("res://Upgrades/Paddle.tscn")
var _armor : PackedScene = preload("res://Upgrades/Armor.tscn")
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
enum _upgrades_enum {NOTHING, CANNON, SAIL, PADDLE, ARMOR}
var _upgrades_items : Array

func _ready() -> void:
	_upgrades_items = [null, _cannon, _sail, _paddle, _armor]
	_dialog.get_close_button().disabled = true
	_dialog.get_close_button().visible = false
	_alert_dialog.get_close_button().disabled = true
	_alert_dialog.get_close_button().visible = false

func _input(event: InputEvent) -> void:
	if player:
		if (event.is_action_pressed("customize") 
			and not _left_tween.is_active() 
			and not _right_tween.is_active()):
			
			if not _inventory_open:
				_left_button.visible = true
				_right_button.visible = true
				_left_tween_setup(_left_button.rect_position, 
					_left_button.rect_position - tween_final_position)
				_right_tween_setup(_right_button.rect_position, 
					_right_button.rect_position + tween_final_position)
			
			elif _inventory_open:
				_left_tween_setup(_left_button.rect_position, 
					_left_button.rect_position + tween_final_position)
				_right_tween_setup(_right_button.rect_position, 
					_right_button.rect_position - tween_final_position)
				
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
	player.extra_speed = 0
	player.damage_negation = 0
	
	if (_right_tool == _sail):
		player.extra_speed += sail_speed_additive
	elif (_right_tool == _paddle):
		player.turn_multiplier += paddle_turn_additive
	elif (_right_tool == _armor):
		player.damage_negation += armor_damage_negation
	
	if (_left_tool == _sail):
		player.extra_speed += sail_speed_additive
	elif (_left_tool == _paddle):
		player.turn_multiplier += paddle_turn_additive
	elif (_left_tool == _armor):
		player.damage_negation += armor_damage_negation

func _select_upgrade(upgrade: String, index: int, is_right: bool) -> void:
	var tools = GameManager.get_tools()
	
	if not tools.get(upgrade).unlocked:
		if is_right:
			_right_button.selected = 0
		else:
			_left_button.selected = 0
			
		_dialog.dialog_text = "Acheter pour %s bois, %s pierres et %s poudre à canon?" \
			% [tools.get(upgrade).wood, tools.get(upgrade).stone, tools.get(upgrade).gunpowder]
		_last_selected_item.wood = tools.get(upgrade).wood
		_last_selected_item.stone = tools.get(upgrade).stone
		_last_selected_item.gunpowder = tools.get(upgrade).gunpowder
		_last_selected_item.name = upgrade
		_dialog.popup()
	else:
		if is_right:
			player.set_right_tool(_upgrades_items[index])
			_right_tool = _upgrades_items[index]
		else:
			player.set_left_tool(_upgrades_items[index])
			_left_tool = _upgrades_items[index]

func _select_item(is_right: bool, index: int) -> void:
	_last_selected_item.is_right = is_right
	_last_selected_item.index = index
	
	
	if player:
		match index:
			_upgrades_enum.NOTHING:
				if is_right:
					player.clear_right_tool()
					_right_tool = null
				else:
					player.clear_left_tool()
					_left_tool = null
			_upgrades_enum.CANNON:
				_select_upgrade("cannon", index, is_right)
			_upgrades_enum.SAIL:
				_select_upgrade("sail", index, is_right)
			_upgrades_enum.PADDLE:
				_select_upgrade("paddle", index, is_right)
			_upgrades_enum.ARMOR:
				_select_upgrade("armor", index, is_right)


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
