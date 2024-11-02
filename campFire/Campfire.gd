extends Node3D

@onready var F1 = $Frame1
@onready var F2 = $Frame2
var flickerTime = 0.5
var flickerCounter = 0
var t = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	flickerCounter += delta
	if flickerCounter > flickerTime:
		t = !t
		flickerTime = 0
		F1.visible = t
		F2.visible = !t
