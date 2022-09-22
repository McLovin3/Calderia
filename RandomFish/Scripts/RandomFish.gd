extends Sprite
class_name RandomFish

export var sprite_path := "res://RandomFish/Sprites/"
export var sprite_scale := Vector2(2, 2)

func _ready():
	var fish_sprites := [] 
	# https://godotengine.org/qa/62238/how-to-preload-folders-worth-of-images-and-put-them-into-array
	var directory := Directory.new()
	directory.open(sprite_path)
	directory.list_dir_begin()
	while true:
		var current_file := directory.get_next()
		
		if current_file == "":
			break;
		
		elif current_file.ends_with(".png"):
			fish_sprites.append(current_file)
	
	randomize()
	var fish_sprite = load(sprite_path + fish_sprites[randi() % fish_sprites.size()])
	texture = fish_sprite
	scale = sprite_scale

func _on_TTL_timeout():
	queue_free()

