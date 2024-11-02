extends Node3D

@onready var sprite = $Sprite
var t1 = load("res://campFire/Fire_1.png")
var t2 = load("res://campFire/Fire_2.png")
var flickerTime = 0.5
var flickerCounter = 0
var t = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	flickerCounter += delta
	if flickerCounter > flickerTime:
		t = !t
		flickerCounter = 0
		if t:
			sprite.mesh.material.albedo_texture = t1
		else:
			sprite.mesh.material.albedo_texture = t2
