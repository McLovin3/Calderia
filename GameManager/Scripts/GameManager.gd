extends Node2D

onready var _customization_menu : CustomizationMenu = $HUD/CustomizationMenu
onready var _stone_label : Label = $HUD/Stone/StoneCount
onready var _wood_label : Label = $HUD/Wood/WoodCount
onready var _gunpowder_label : Label = $HUD/Gunpowder/GunpowderCount
onready var _health_bar : ProgressBar = $HUD/HealthBar
onready var _dash_bar : ProgressBar = $HUD/DashBar

var _save_path : String = "user://savegame.save"
var _data : Dictionary = \
	{
		"ressources" : 
			{
				"wood" : 0, 
				"stone" : 0,
				"gunpowder": 0
			}, 
		"tools": 
			{
				"cannon" : 
					{
						"unlocked" : false,
						"wood" : 0,
						"stone" : 100,
						"gunpowder" : 50
					}
			}
	} 

func _ready() -> void:
	_load_game()

func _load_game() -> void:
	var save_file := File.new()
	if not save_file.file_exists(_save_path):
		_save_game()
	
	var _error = save_file.open_encrypted_with_pass(_save_path, File.READ, "McLovin")
	_data = parse_json(save_file.get_line())
	
	_update_labels()
	
	save_file.close()

func _save_game() -> void:
	var save_file := File.new()
	var _error = save_file.open_encrypted_with_pass(_save_path, File.WRITE, "McLovin")
	save_file.store_line(to_json(_data))
	save_file.close()

func _update_labels() -> void:
	_stone_label.text = String(_data.ressources.stone)
	_wood_label.text = String(_data.ressources.wood)
	_gunpowder_label.text = String(_data.ressources.gunpowder)

func _on_SaveInterval_timeout() -> void:
	_save_game()

func add_wood(amount: int) -> void:
	_data.ressources.wood += amount
	_update_labels()
	_save_game()

func add_stone(amount: int) -> void:
	_data.ressources.stone += amount
	_update_labels()
	_save_game()

func add_gunpowder(amount: int) -> void:
	_data.ressources.gunpowder += amount
	_update_labels()
	_save_game()

func set_hp(current_health : float, max_health : float) -> void:
	_health_bar.value = (current_health * _health_bar.max_value) / max_health 

func set_dash(current_dash : float, max_dash : float) -> void:
	_dash_bar.value = (current_dash * _dash_bar.max_value) / max_dash

func set_player(player: PlayerShip) -> void:
	_customization_menu.player = player

func get_tools() -> Dictionary:
	return _data.tools

func get_ressources() -> Dictionary:
	return _data.ressources

func set_ressources(ressources : Dictionary) -> void:
	_data.ressources = ressources
	_update_labels()
	_save_game()

func unlock_item(tool_name : String) -> void:
	var selected_tool : Dictionary = _data.tools.get(tool_name)
	
	selected_tool.unlocked = true
	_data.ressources.wood -= selected_tool.wood
	_data.ressources.stone -= selected_tool.stone
	_data.ressources.gunpowder -= selected_tool.gunpowder
	
	_update_labels()
	_save_game()
