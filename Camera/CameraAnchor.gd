extends Node3D
class_name CameraAnchor

func _ready() -> void:
	$Platform.top_level = true
	
func _process(delta: float) -> void:
	$Platform.position = position

func getCamera():
	return $Camera3D
	
func getShader():
	return $Camera3D/Shader.mesh.material
	
func getShaderObj():
	return $Camera3D/Shader
