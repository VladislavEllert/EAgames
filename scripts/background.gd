extends Parallax2D

@onready var sprite = $Sprite2D

func _ready():

	var texture_size = sprite.texture.get_size()
	repeat_size = texture_size
	
	print("Фон настроен! Размер: ", texture_size)

func _process(delta):
	scroll_offset.y -= 10 * delta
