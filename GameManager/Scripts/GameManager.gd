extends Node2D

onready var _hud : HUD = $HUD
onready var _customization_menu : CustomizationMenu = $CustomizationMenu

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
					},
				"sail" :
					{
						"unlocked" : false,
						"wood" : 150,
						"stone" : 0,
						"gunpowder" : 0
					}
			}
	} 


func _ready() -> void:
	_load_game()
	add_wood(200)
	add_stone(200)
	add_gunpowder(200)


func _load_game() -> void:
	var save_file := File.new()
	if not save_file.file_exists(_save_path):
		_save_game()
	
	var _error = save_file.open_encrypted_with_pass(_save_path, File.READ, "McLovin")
	_data = parse_json(save_file.get_line())
	
	_hud.set_ressources(_data.ressources)
	
	save_file.close()


func _save_game() -> void:
	var save_file := File.new()
	var _error = save_file.open_encrypted_with_pass(_save_path, File.WRITE, "McLovin")
	save_file.store_line(to_json(_data))
	save_file.close()


func _on_SaveInterval_timeout() -> void:
	_save_game()


func add_wood(amount: int) -> void:
	_data.ressources.wood += amount
	_hud.set_wood(amount)
	_save_game()


func add_stone(amount: int) -> void:
	_data.ressources.stone += amount
	_hud.set_stone(amount)
	_save_game()


func add_gunpowder(amount: int) -> void:
	_data.ressources.gunpowder += amount
	_hud.set_gunpowder(amount)
	_save_game()


func set_player(player : PlayerShip) -> void:
	_customization_menu.player = player


func set_hp(current_health : float, max_health : float) -> void:
	_hud.set_hp(current_health, max_health)


func set_energy(current_energy : float, max_energy : float) -> void:
	_hud.set_energy(current_energy, max_energy)


func get_tools() -> Dictionary:
	return _data.tools


func get_ressources() -> Dictionary:
	return _data.ressources


func set_ressources(ressources : Dictionary) -> void:
	_data.ressources = ressources
	_hud.set_ressources(ressources)
	_save_game()


func unlock_item(tool_name : String) -> void:
	var selected_tool : Dictionary = _data.tools.get(tool_name)
	
	selected_tool.unlocked = true
	_data.ressources.wood -= selected_tool.wood
	_data.ressources.stone -= selected_tool.stone
	_data.ressources.gunpowder -= selected_tool.gunpowder
	
	_hud.set_ressources(_data.ressources)
	_save_game()
