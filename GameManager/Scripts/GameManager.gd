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
	
	var _error = save_file.open_encrypted_with_pass(_save_path, File.READ, "McLovin")
	_ressources = parse_json(save_file.get_line())
	
	_update_labels()
	
	save_file.close()

func _save_game() -> void:
	var save_file := File.new()
	var _error = save_file.open_encrypted_with_pass(_save_path, File.WRITE, "McLovin")
	save_file.store_line(to_json(_ressources))
	save_file.close()

func _update_labels() -> void:
	_stone_label.text = String(_ressources.stone)
	_wood_label.text = String(_ressources.wood)

func _on_SaveInterval_timeout() -> void:
	_save_game()

func add_wood(amount: int) -> void:
	_ressources.wood += amount
	_update_labels()
	_save_game()
	
func add_stone(amount: int) -> void:
	_ressources.stone += amount
	_update_labels()
	_save_game()
