extends Control


func _ready() -> void:
	var player = get_tree().get_root().get_node("Main").get_node("Player")
	player.currentHealthUpdated.connect(_on_checkGameOver)
	visible = false


func showGameoverUI():
	await get_tree().create_timer(1).timeout
	visible = true


func _on_checkGameOver(newValue):
	if newValue <= 0:
		showGameoverUI()


func _on_restart_btn_pressed() -> void:
	get_tree().reload_current_scene()
