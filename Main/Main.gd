extends Node3D

var monsterScene = preload("res://Monster/Monster.tscn")
var isRunning = false # check if mosnter timer is running
var isRunningSpawn = false # check if spawn timer is running

@onready var monsterTimer = $Timers/MonsterTimer
@onready var spawnTimer = $Timers/SpawnTimer
@onready var player: Player = get_node("Player")
@onready var messager: Messager = $Messager
@onready var eyes: Eyes = $Player/Eyes

var monsterHint = "It is pitch black. You are likely to be eaten by a grue."
var monsterHinted = false
var spawnInt = 10.0 # timer for monsters to spawn
var minSpawnInt = 2.0 # fastest time monsters will start spawning
var intervalDecrement = 1.0 # value for slowly decreasing spawn timer

func _physics_process(delta: float) -> void:
	if !player.getInside():
		if !isRunning:
			monsterTimer.start()
			isRunning = true
			
		if monsterTimer.time_left < 10 && monsterHinted == false:
			monsterHinted = true
			messager.setMessage(monsterHint)
		elif monsterTimer.time_left < 5 && messager.text == monsterHint:
			messager.delMessage()
	else:
		spawnTimer.stop()
		isRunning = false
		isRunningSpawn = false
		monsterHinted = false
		eyes.cover()
			
func _on_monster_timer_timeout():
	print("Monster Timer Ran Out")
	monsterTimer.stop()
	spawnTimer.start()
	isRunningSpawn = true 
	player.makeOutlineRed()
	eyes.uncover()
	spawnMonster()
	spawnMonster()

func _on_spawn_timer_timeout():
	spawnMonster()
	spawnInt = max(spawnInt - intervalDecrement, minSpawnInt)
	spawnTimer.wait_time = spawnInt

func spawnMonster():
	print("Spawning Monster")
	var monster = monsterScene.instantiate()
	var dir = player.velocity.normalized()
	if dir.length() == 0:
		dir = player.transform.basis.z.normalized() * -1
	
	var spawn = player.global_transform.origin + dir * 10.0
	monster.global_transform.origin = spawn
	get_tree().current_scene.add_child(monster)
