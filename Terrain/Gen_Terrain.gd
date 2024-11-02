extends Node3D

var tree = load("res://Terrain/Tree/Tree.tscn")
var grass = load("res://Terrain/Grass/Grass.tscn")
var stick = load("res://Collectables/Stick.tscn")
var monsterScene = preload("res://Monster/Monster.tscn")
var isRunning = false # check if mosnter timer is running
var isRunningSpawn = false # check if spawn timer is running
var spawnInt = 10.0 # timer for monsters to spawn
var minSpawnInt = 2.0 # fastest time monsters will start spawning
var intervalDecrement = 1.0 # value for slowly decreasing spawn timer
var terrain_items = []
var COUNT = 1000 # how many to gen
var DISTANCE = 100 # radius from center

@onready var monsterTimer = $MonsterTimer
@onready var spawnTimer = $SpawnTimer
@onready var stickScore = $StickScore
@onready var player = get_node("Player")



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# on load - generate 10 sticks
	generateStick(100)
	
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
		

func generateStick(num: int):
	for i in range(num):
		var node: Node3D
		
		node = stick.instantiate()
			
		node.position.x = (randf()-0.5)*DISTANCE*2
		node.position.z = (randf()-0.5)*DISTANCE*2
		add_child(node)


#func timedSticks():
	

func _physics_process(delta):
	if player:
		for each in terrain_items:
			if each.position.z > player.position.z+6:
				each.visible = false
			else:
				each.visible = true

	if !player.getInside():
		if !isRunning:
			monsterTimer.start()
			isRunning = true
	else:
			spawnTimer.stop()
			isRunning = false
			isRunningSpawn = false
	stickScore.text = "x " + str(player.stickCounter)

func _on_monster_timer_timeout():
	print("Monster Timer Ran Out")
	monsterTimer.stop()
	spawnTimer.start()
	isRunningSpawn = true 


func _on_spawn_timer_timeout():
	print("Spawning Monster")
	var monster = monsterScene.instantiate()
	var dir = player.velocity.normalized()
	if dir.length() == 0:
		dir = player.transform.basis.z.normalized() * -1
	
	var spawn = player.global_transform.origin + dir * 10.0
	monster.global_transform.origin = spawn
	get_tree().current_scene.add_child(monster)
	
	spawnInt = max(spawnInt - intervalDecrement, minSpawnInt)
	spawnTimer.wait_time = spawnInt
