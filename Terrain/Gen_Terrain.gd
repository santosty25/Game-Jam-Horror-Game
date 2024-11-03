extends Node3D

var tree = load("res://Terrain/Tree/Tree.tscn")
var grass = load("res://Terrain/Grass/Grass.tscn")
var stick = load("res://Collectables/Stick.tscn")

var terrain_items = []
var COUNT = 1000 # how many to gen
var DISTANCE = 100 # radius from center
var SAFE_DIST = 10 # dont generate in this radius
var STICK_MIN_RAD = 20

#@onready var player = get_node("Player")
@export var player: Player

# Called when the node enters the scene tree for the first time.
func generate() -> void:
	print("generate")
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
		if node.position.length() < SAFE_DIST:
			node.queue_free()
		else:
			terrain_items.append(node)
			add_child(node)
		
#func generateStick(num: int):
	#for i in range(num):
		#var node: Node3D
		#
		#node = stick.instantiate()
		#node.set_player(player)
		#node.position.x = (randf()-0.5)*DISTANCE*2
		#node.position.z = (randf()-0.5)*DISTANCE*2
		#add_child(node)

func generateStick(num: int):
	for i in range(-num,num+1):
		for j in range(-num,num+1):
			var node: Node3D
		
			node = stick.instantiate()
			node.set_player(player)
			node.position.x = i * 20
			node.position.z = j * 20
			var offset = Vector3(randf(),0,randf()).normalized()*randf()*20
			node.position += offset
			if node.position.length() >= STICK_MIN_RAD:
				add_child(node)

func regenStick(pos: Array):
	var node: Node3D
	node = stick.instantiate()
	node.set_player(player)
	node.position.x = pos[0]
	node.position.y = pos[1]
	node.position.z = pos[2]
	add_child(node)
	



func _physics_process(delta):
	
	if player:
		for each in terrain_items:
			if each.position.z > player.position.z+6:
				each.visible = false
			else:
				each.visible = true
	
	if player.getFull() == true:
		regenStick(player.getRespondLoc())
