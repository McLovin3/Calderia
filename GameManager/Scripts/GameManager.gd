extends Node2D

onready var _customization_menu : CustomizationMenu = $HUD/CustomizationMenu
onready var _stone_label : Label = $HUD/Stone/StoneCount
onready var _wood_label : Label = $HUD/Wood/WoodCount
onready var _health_bar : ProgressBar = $HUD/HealthBar
onready var _dash_bar : ProgressBar = $HUD/DashBar

var _save_path : String = "user://savegame.save"
var data : Dictionary = \
	{
		"ressources" : 
			{
				"wood" : 0, 
				"stone" : 0}, 
		"tools": 
			{
				"leftTools" : 
					{
						"cannon" : 
							{
								"unlocked" : false,
								"price" : 
									{
										"wood" : 100,
										"stone" : 100
									}
							}
					},
				"rightTools" : 
					{
						"cannon" : 
							{
								"unlocked" : false,
								"price" : 
									{
										"wood" : 100,
										"stone" : 100
									}
							}
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
	data = parse_json(save_file.get_line())
	
	_update_labels()
	
	save_file.close()

func _save_game() -> void:
	var save_file := File.new()
	var _error = save_file.open_encrypted_with_pass(_save_path, File.WRITE, "McLovin")
	save_file.store_line(to_json(data))
	save_file.close()

func _update_labels() -> void:
	_stone_label.text = String(data.ressources.stone)
	_wood_label.text = String(data.ressources.wood)

func _on_SaveInterval_timeout() -> void:
	_save_game()

func add_wood(amount: int) -> void:
	data.ressources.wood += amount
	_update_labels()
	_save_game()

func set_hp(current_health : float, max_health : float) -> void:
	_health_bar.value = (current_health * _health_bar.max_value) / max_health 

func set_dash(current_dash : float, max_dash : float) -> void:
	_dash_bar.value = (current_dash * _dash_bar.max_value) / max_dash

func add_stone(amount: int) -> void:
	data.ressources.stone += amount
	_update_labels()
	_save_game()

func set_player(player: PlayerShip) -> void:
	_customization_menu.player = player

func get_tools() -> Dictionary:
	return data.tools

func get_ressources() -> Dictionary:
	return data.ressources

func set_ressources(ressources : Dictionary) -> void:
	data.ressources = ressources
	_save_game()
	_update_labels()

func unlock_item(isRightSide : bool, tool_name : String) -> void:
	if isRightSide:
		data.tools.rightTools.get(tool_name).unlocked = true
	
	else:
		data.tools.leftTools.get(tool_name).unlocked = true
	
	_save_game()
