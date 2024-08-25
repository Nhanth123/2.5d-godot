extends HBoxContainer

@export var fullHeartTexture: Texture2D
@export var emptyHeartTexture: Texture2D
var heartTextureRectArray : Array[TextureRect]

func _ready():
	var player = get_tree().get_root().get_node("Main").get_node("Player")
	player.currentHealthUpdated.connect(_on_updateHearts)
	
	for item in get_children():
		heartTextureRectArray.append(item)
		
func _on_updateHearts(newValue):
	var fullHeartNumber = newValue
	
	for item in heartTextureRectArray:
		if fullHeartNumber > 0:
			fullHeartNumber -= 1
			item.texture = fullHeartTexture
		else:
			item.texture = emptyHeartTexture
