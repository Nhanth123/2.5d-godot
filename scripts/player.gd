extends CharacterBody3D

@onready var root_node: Node3D = $Visual/RootNode


const  SPEED = 10
const  JUMP_VELOCITY = 22


var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _physics_process(delta):
	
#region Rotate the Player to moving the direction Region
	if velocity.x != 0:
		var faceRight = velocity.x > 0
		if faceRight:
			root_node.rotation = Vector3(0,0,0)
		else:
			root_node.rotation = Vector3(0,PI,0)
#endregion
		
	
	if not is_on_floor():
		velocity.y -= gravity * delta * 8
	
	if Input.is_action_just_pressed("ui_accept")and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up","ui_down")
	var direction =  (transform.basis * Vector3(input_dir.x, 0 , input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, 1)
	
	move_and_slide()
	
