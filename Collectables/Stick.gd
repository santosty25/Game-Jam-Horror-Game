extends Node3D
class_name Stick

var player 
signal stick_nearby
		
func pickup():
	#player.add_child(self)
	queue_free()

func set_player(p):
	player = p

func _on_area_3d_body_entered(body: Node3D) -> void:
	print("stick")
	if body is Player:
		player = body
		emit_signal("stick_nearby", self)
