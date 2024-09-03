extends CharacterBody3D

class_name Player

@onready var root_node: Node3D = $Visual/RootNode
@onready var animation_tree: AnimationTree = $Visual/AnimationTree
@onready var footstep_vfx: GPUParticles3D = $Visual/RootNode/VFX/Footstep_VFX
@onready var animation_player_material: AnimationPlayer = $Visual/AnimationPlayer_Material
@onready var heal_player_vfx: GPUParticles3D = $Visual/RootNode/VFX/HEAL_Player_VFX
@onready var melee_vfx = $Visual/RootNode/VFX/MELEE_VFX
@onready var area_3d_hitbox: Area3D = $Visual/RootNode/Area3D_Hitbox
@onready var animation_player_blade_vfx: AnimationPlayer = $Visual/RootNode/VFX/AnimationPlayer_BladeVFX

const SPEED = 10
const JUMP_VELOCITY = 22
const maxHealth = 3

var currentHealth
var controllable = true

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var isInvicible = false

var uncontrolableRemain = 0
var getHurtCooldown = 1
var meleeAttackCooldown = 0.6
var meleeAttackDamage = 10

signal currentHealthUpdated(newValue)

func _ready() -> void:
	currentHealth = maxHealth
	area_3d_hitbox.monitoring = false
	

func _process(_delta):
	
	handMovementVFX()
	
	if currentHealth <= 0:
		return
	
	animation_tree.set("parameters/StateMachine/GroundMovement/blend_position", abs(velocity.x))
	animation_tree.set("parameters/StateMachine/Airborne/blend_position", velocity.y)
	
	if is_on_floor():
		animation_tree.changeStateToNormal()
	else:
		animation_tree.changeStateToAirborne()
	
	if controllable == false && currentHealth > 0:
		uncontrolableRemain -= _delta
		if uncontrolableRemain <= 0:
			uncontrolableRemain = 0
			controllable = true
	
	if controllable == true && Input.is_action_just_pressed("MeleeAttack"):
		controllable = false
		uncontrolableRemain += meleeAttackCooldown
		
		animation_tree.set("parameters/OneShotMelee/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		animation_player_blade_vfx.play("PlayBladeVFX")
		
		area_3d_hitbox.monitoring = true
		await get_tree().create_timer(0.3).timeout
		area_3d_hitbox.monitoring = false
		
	

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
	controllable = false
	
	uncontrolableRemain += getHurtCooldown
	
	isInvicible = true
	currentHealthUpdated.emit(currentHealth)
	
	if currentHealth <= 0 :
		animation_tree.changeStateToDead()
	else:
		animation_tree.set("parameters/OneShotMelee/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
		animation_tree.set("parameters/OneShotHurt/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		animation_player_material.play("Flash_Invincible")
		await get_tree().create_timer(2).timeout
		animation_player_material.play("RESET")
		isInvicible = false
		

func updateHorizontalVelocity():
	velocity.x = move_toward(velocity.x, 0, 1)
	
func updateVerticalVelocity(delta):
	velocity.y -= gravity * delta * 8

func addHealth():
	if currentHealth == maxHealth:
		return false
		
	currentHealth += 1
	animation_player_material.play("Flash_Heal")
	heal_player_vfx.restart()
	
	currentHealthUpdated.emit(currentHealth)
	return true


func _on_area_3d_hitbox_body_entered(body: Node3D) -> void:
	body.applyDamage(meleeAttackDamage)
