extends CharacterBody3D


const SPEED = 1.4

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var ray_cast_3d_forward = $CollisionShape3D/RayCast3D_Forward
@onready var ray_cast_3d_downward = $CollisionShape3D/RayCast3D_Downward
@onready var root_node: Node3D = $Visual/RootNode
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var animation_player: AnimationPlayer = $Visual/AnimationPlayer
@onready var animation_player_material: AnimationPlayer = $Visual/AnimationPlayer_Material


var direction
var facingRight = true

func _ready() -> void:
	animation_player.play("NPC_01_WALK")
	
func _process(delta: float):
	if not is_on_floor():
		velocity.y -= gravity * delta * 5
	
	
	if ray_cast_3d_forward.is_colliding() || ray_cast_3d_downward.is_colliding() == false:
		facingRight = !facingRight
	
		
	if facingRight:
		direction = 1
		root_node.rotation = Vector3(0, 0, 0)
		collision_shape_3d.rotation = Vector3(0 , 0, 0)
	else:
		direction = -1
		root_node.rotation = Vector3(0, PI, 0)
		collision_shape_3d.rotation = Vector3(0, PI, 0)

	velocity.x = direction * SPEED
	
	move_and_slide()


func _on_area_3d_body_entered(body: Node3D) -> void:
	body.applyDamage()


func applyDamage(_damage: int):
	animation_player_material.play("Flash")
	
