extends Node2D

var _save_path = "user://savegame.save"
var _ressources := {"wood" : 0, "stone" : 0}

onready var _stone_label : Label = $HUD/Stone/StoneCount
onready var _wood_label : Label = $HUD/Wood/WoodCount

func _ready() -> void:
	_load_game()

func _load_game() -> void:
	var save_file := File.new()
	if not save_file.file_exists(_save_path):
		_save_game()
	
	var error = save_file.open_encrypted_with_pass(_save_path, File.READ, "McLovin")
	_ressources = parse_json(save_file.get_line())
	
	print(_ressources)
	
	_stone_label.text = String(_ressources.stone)
	_wood_label.text = String(_ressources.wood)
	
	save_file.close()

func _save_game() ->void:
	var save_file := File.new()
	var error = save_file.open_encrypted_with_pass(_save_path, File.WRITE, "McLovin")
	save_file.store_line(to_json(_ressources))
	save_file.close()

func _on_SaveInterval_timeout():
	_save_game()
