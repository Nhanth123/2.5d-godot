extends Node3D


@onready var heal_mesh: Node3D = $HEAL_MESH

func _process(delta: float) -> void:
	heal_mesh.rotate_y(delta)


func _on_area_3d_body_entered(body: Node3D) -> void:
	var result = body.addHealth
	
	if result:
		queue_free()
		
