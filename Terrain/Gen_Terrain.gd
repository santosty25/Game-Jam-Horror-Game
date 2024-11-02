extends Node3D

@onready var monsterTimer = $MonsterTimer
@onready var spawnTimer = $SpawnTimer
@onready var player = get_node("Player")

var tree = load("res://Terrain/Tree/Tree.tscn")
var grass = load("res://Terrain/Grass/Grass.tscn")

var COUNT = 30 # how many to gen
var DISTANCE = 10 # radius from center

var monsterScene = preload("res://Monster/Monster.tscn")
var isRunning = false # check if mosnter timer is running
var isRunningSpawn = false # check if spawn timer is running
var spawnInt = 10.0 # timer for monsters to spawn
var minSpawnInt = 2.0 # fastest time monsters will start spawning
var intervalDecrement = 1.0 # value for slowly decreasing spawn timer

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
		add_child(node)

func _physics_process(delta):
	if !player.getInside():
		if !isRunning:
			monsterTimer.start()
			isRunning = true
	else:
			spawnTimer.stop()
			isRunning = false
			isRunningSpawn = false
			
func _on_monster_timer_timeout():
	print("Monster Timer Ran Out")
	monsterTimer.stop()
	spawnTimer.start()
	isRunningSpawn = true 


func _on_spawn_timer_timeout():
	print("Spawning Monster")
	var monster = monsterScene.instantiate()
	var randDir =  Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized()
	var spawn = player.global_transform.origin + randDir * 15.0
	monster.global_transform.origin = spawn
	get_tree().current_scene.add_child(monster)
	
	spawnInt = max(spawnInt - intervalDecrement, minSpawnInt)
	spawnTimer.wait_time = spawnInt
