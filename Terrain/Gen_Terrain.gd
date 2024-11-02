extends Node3D

var tree = load("res://Terrain/Tree/Tree.tscn")
var grass = load("res://Terrain/Grass/Grass.tscn")
@export var player: CharacterBody3D

var terrain_items = []

var COUNT = 1000 # how many to gen
var DISTANCE = 100 # radius from center

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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
		terrain_items.append(node)
		add_child(node)
	
func _physics_process(delta: float) -> void:
	if player:
		for each in terrain_items:
			if each.position.z > player.position.z+6:
				each.visible = false
			else:
				each.visible = true
