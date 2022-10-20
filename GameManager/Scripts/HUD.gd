extends CanvasLayer
class_name HUD

onready var _stone_label : Label = $Stone/StoneCount
onready var _wood_label : Label = $Wood/WoodCount
onready var _gunpowder_label : Label = $Gunpowder/GunpowderCount
onready var _health_bar : ProgressBar = $HealthBar
onready var _energy_bar : ProgressBar = $DashBar
onready var _controls_container : PanelContainer = $ControlsContainer


func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("controls")):
		_controls_container.visible = true
		get_tree().paused = true
	
	elif (event.is_action_released("controls")):
		_controls_container.visible = false
		get_tree().paused = false


func set_ressources(ressources: Dictionary) -> void:
	_stone_label.text = String(ressources.stone)
	_wood_label.text = String(ressources.wood)
	_gunpowder_label.text = String(ressources.gunpowder)


func set_wood(amount : int) -> void:
	_wood_label.text = String(amount)


func set_stone(amount : int) -> void:
	_stone_label.text = String(amount)


func set_gunpowder(amount : int) -> void:
	_gunpowder_label.text = String(amount)


func set_hp(current_health : float, max_health : float) -> void:
	_health_bar.value = (current_health * _health_bar.max_value) / max_health 


func set_energy(current_energy : float, max_energy : float) -> void:
	_energy_bar.value = (current_energy * _energy_bar.max_value) / max_energy
