extends CharacterBody3D
class_name Stick


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var player 

signal stick_nearby

func _ready():
	player = get_node("Player")
	
func _physics_process(delta: float) -> void:
	pass# Add the gravity.
	

func _on_area_3d_body_entered(body: CharacterBody3D) -> void:
	if body is Player:
		emit_signal("stick_nearby", self)
		
		
func pickup():
	self.get_parent_node_3d().remove_child(self)
	player.add_child(self)
	self.position = Vector3(0,1,1)
