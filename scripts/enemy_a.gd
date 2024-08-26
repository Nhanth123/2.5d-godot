extends CharacterBody3D


const SPEED = 1.5

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta * 5
	
	move_and_slide()
