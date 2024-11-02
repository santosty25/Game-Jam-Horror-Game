extends Node3D

var tree = load("res://Terrain/Tree/Tree.tscn")
var grass = load("res://Terrain/Grass/Grass.tscn")
var stick = load("res://Collectables/Stick.tscn")

var COUNT = 30 # how many to gen
var DISTANCE = 10 # radius from center

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# on load - generate 10 sticks
	generateStick(50)
	
	for i in range(COUNT):
		var node: Node3D
		
		# choose which to generate
		if randf() < 0.5:
			node = tree.instantiate()
		else:
			node = grass.instantiate()
			
		# assign random position and show
		node.position.x = (randf()-0.5)*DISTANCE*2
		node.position.z = (randf()-0.5)*DISTANCE*2
		add_child(node)
		
func generateStick(num: int):
	for i in range(num):
		var node: Node3D
		
		node = stick.instantiate()
		node.position.x = (randf()-0.5)*DISTANCE*2
		node.position.z = (randf()-0.5)*DISTANCE*2
		add_child(node)

#func timedSticks():
	
