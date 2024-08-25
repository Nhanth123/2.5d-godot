extends CharacterBody3D

class_name Player

@onready var root_node: Node3D = $Visual/RootNode
@onready var animation_tree: AnimationTree = $Visual/AnimationTree
@onready var footstep_vfx: GPUParticles3D = $Visual/VFX/Footstep_VFX
@onready var animation_player_material: AnimationPlayer = $Visual/AnimationPlayer_Material


const SPEED = 10
const JUMP_VELOCITY = 22
const maxHealth = 3

var currentHealth
var controllable = true

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var isInvicible = false

signal currentHealthUpdated(newValue)

func _ready() -> void:
	currentHealth = maxHealth
	

func _process(_delta):
	
	handMovementVFX()
	
	animation_tree.set("parameters/StateMachine/GroundMovement/blend_position", abs(velocity.x))
	animation_tree.set("parameters/StateMachine/Airborne/blend_position", velocity.y)
	
	if is_on_floor():
		animation_tree.changeStateToNormal()
	else:
		animation_tree.changeStateToAirborne()


func _physics_process(delta):
	if controllable == false:
		updateHorizontalVelocity()
		updateVerticalVelocity(delta)
		move_and_slide()
		return
		
#region Rotate the Player to moving the direction Region
	if velocity.x != 0:
		var faceRight = velocity.x > 0
		if faceRight:
			root_node.rotation = Vector3(0,0,0)
		else:
			root_node.rotation = Vector3(0,PI,0)
#endregion

	if not is_on_floor():
		updateVerticalVelocity(delta)
	
	if Input.is_action_just_pressed("jump"): #and is_on_floor():
		velocity.y = JUMP_VELOCITY
		playGroundSmokeVFX()
	
	var horizontalInput = Input.get_axis("move_left", "move_right")
		
	if horizontalInput:
		horizontalInput = int(horizontalInput)
		velocity.x = horizontalInput * SPEED
	else:
		updateHorizontalVelocity()
		velocity.x = move_toward(velocity.x, 0, 1)
	
	move_and_slide()
	
func handMovementVFX():
	if is_on_floor():
		if velocity.x != 0 :
			footstep_vfx.emitting = true
		else:
			footstep_vfx.emitting = false
	else:
		footstep_vfx.emitting = false
		
	if is_on_floor():
		if animation_tree.checkIfStateIsAirborne():
			playGroundSmokeVFX()


func playGroundSmokeVFX():
	var vfxToSpawm = preload("res://assets/VFX/Scene/land_vfx.tscn")
	var vfxInstance = vfxToSpawm.instantiate()
	
	get_tree().get_root().get_node("Main").add_child(vfxInstance)
	vfxInstance.global_position = global_position + Vector3(0, 0.3, 0.2)
	vfxInstance.restart()
	
	await get_tree().create_timer(0.6).timeout
	vfxInstance.queue_free()

func applyDamage():
	if currentHealth == 0 || isInvicible:
		return
	
	currentHealth -= 1
	#print(currentHealth)
	controllable = false
	isInvicible = true
	currentHealthUpdated.emit(currentHealth)
	
	
	if currentHealth <= 0 :
		animation_tree.changeStateToDead()
	else:
		animation_tree.set("parameters/OneShotHurt/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		animation_player_material.play("Flash_Invincible")
		await get_tree().create_timer(0.9).timeout
		controllable = true
		await get_tree().create_timer(1.0).timeout
		animation_player_material.play("RESET")
		isInvicible = false
		

func updateHorizontalVelocity():
	velocity.x = move_toward(velocity.x, 0, 1)
	
func updateVerticalVelocity(delta):
	velocity.y -= gravity * delta * 8
