extends Node3D

var monsterScene = preload("res://Monster/Monster.tscn")
var isRunning = false # check if mosnter timer is running
var isRunningSpawn = false # check if spawn timer is running

@onready var monsterTimer = $Timers/MonsterTimer
@onready var spawnTimer = $Timers/SpawnTimer
@onready var stickScore = $UI/StickScore
@onready var player: Player = get_node("Player")

var spawnInt = 10.0 # timer for monsters to spawn
var minSpawnInt = 2.0 # fastest time monsters will start spawning
var intervalDecrement = 1.0 # value for slowly decreasing spawn timer

func _physics_process(delta: float) -> void:
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
	player.makeOutlineRed()

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
