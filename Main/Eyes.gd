extends Node3D
class_name Eyes

var coveredPos = Vector3.ZERO
var uncoveredY = 2
var speed = 2
var uncovered = false
@onready var coverObj = $Cover

func _ready() -> void:
	coveredPos = coverObj.position

func _process(delta: float) -> void:
	if uncovered:
		if coverObj.position.y < coveredPos.y+uncoveredY:
			coverObj.position.y += speed*delta
	else:
		if coverObj.position.y > coveredPos.y:
			coverObj.position.y -= speed*delta

func cover():
	uncovered = false

func uncover():
	uncovered = true
