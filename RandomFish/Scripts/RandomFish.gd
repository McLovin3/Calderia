extends Sprite
class_name RandomFish

export var sprite_scale := Vector2(2, 2)

onready var _wood_fish := preload("res://RandomFish/Sprites/WoodFish.png")
onready var _stone_fish := preload("res://RandomFish/Sprites/StoneFish.png")
onready var _gunpowder_fish := preload("res://RandomFish/Sprites/GunpowderFish.png")


func _ready():
	var _fishes := [_wood_fish, _stone_fish, _gunpowder_fish]
	randomize()
	var fish_sprite = _fishes[randi() % _fishes.size()]
	texture = fish_sprite
	scale = sprite_scale

func _on_TTL_timeout():
	queue_free()

