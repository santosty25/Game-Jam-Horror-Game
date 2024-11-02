extends Camera3D

@export var player: Node3D
@onready var shader = $Shader.mesh.material

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var center = Vector3(player.global_position.x,0,player.global_position.z)
	shader.set("shader_parameter/center",center);
