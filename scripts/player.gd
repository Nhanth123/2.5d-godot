extends CharacterBody3D

@onready var root_node: Node3D = $Visual/RootNode
@onready var animation_tree: AnimationTree = $Visual/AnimationTree

const  SPEED = 10
const  JUMP_VELOCITY = 22

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _process(_delta):
	animation_tree.set("parameters/StateMachine/GroundMovement/blend_position", abs(velocity.x))
	animation_tree.set("parameters/StateMachine/Airborne/blend_position", velocity.y)
	
	if is_on_floor():
		animation_tree.changeStateToNormal()
	else:
		animation_tree.changeStateToAirborne()
		

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
	
	if Input.is_action_just_pressed("jump")and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	var horizontalInput = Input.get_axis("move_left", "move_right")
		
	if horizontalInput:
		horizontalInput = int(horizontalInput)
		velocity.x = horizontalInput * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, 1)
	
	move_and_slide()
	
