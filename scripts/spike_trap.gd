extends Node3D


func _on_area_3d_body_entered(body: Node3D) -> void:
	print("Touch the spike: " + body.name)
	#body.applyDamage()
