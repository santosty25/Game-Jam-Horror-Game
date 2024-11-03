extends Node3D

var monsterScene = preload("res://Monster/Monster.tscn")
var isRunning = false # check if mosnter timer is running
var isRunningSpawn = false # check if spawn timer is running
var menuTransition = false
var menu = true
var inGame = false
var creditsShown = false
var monsters = []

@onready var monsterTimer = $Timers/MonsterTimer
@onready var spawnTimer = $Timers/SpawnTimer
@onready var stickScore = $UI/StickScore
@onready var campfire = $CampFire
@onready var terrainManager = $TerrainManager
@export var player: Player
@onready var messager: Messager = $UI/Messager
@onready var eyes: Eyes = $Player/Eyes
@onready var compassArrow = $UI/directionalArrow
@onready var ui = $UI
@onready var mainUI = $MenuItems/MainMenu
@onready var pauseUI = $MenuItems/Pause
@onready var endUI = $MenuItems/GameOver
@onready var fadeOut = $MenuItems/ColorRect
@onready var credits := $MenuItems/Credits
@onready var monsterTimeAudio = $MonsterTimesUp

var monsterHint = "It is pitch black. You are likely to be eaten by a grue."
var monsterHinted = false
var spawnInt = 10.0 # timer for monsters to spawn
var minSpawnInt = 2.0 # fastest time monsters will start spawning
var intervalDecrement = 1.0 # value for slowly decreasing spawn timer
var camp_fire = null
var fadeOutTimer = 1
var creditsTimer = 0
var reset = false
var monsterCount = 20
var total = 2

func _ready() -> void:
	setMenu()
	for each in get_tree().root.get_children():
		if each != self:
			each.queue_free()
	
func setMenu():
	campfire.setMenu()
	player.setMenu()
	eyes.visible = false
	ui.visible = false
	monsterTimer.paused = true
	spawnTimer.paused = true
	pauseMonsters()
	
func pauseMonsters(p=true):
	var i = 0
	while i < len(monsters):
		if monsters[i] != null:
			monsters[i].paused = p
		else:
			monsters.remove_at(i)
			i -= 1
		i += 1
	
func setMainMenu():
	setMenu()
	mainUI.visible = true
	pauseUI.visible = false
	endUI.visible = false
	
func setPauseMenu():
	setMenu()
	pauseUI.visible = true
	mainUI.visible = false
	endUI.visible = false
	
func setEndMenu():
	setMenu()
	endUI.visible = true
	mainUI.visible = false
	pauseUI.visible = false
	
func startGame():
	if !inGame:
		terrainManager.generate()
	player.setGameplay()
	campfire.setGameplay()
	ui.visible = true
	eyes.visible = true
	monsterTimer.paused = false
	spawnTimer.paused = false
	pauseMonsters(false)
	
func hideUI():
	mainUI.visible = false
	pauseUI.visible = false
	endUI.visible = false

func _on_start_pressed() -> void:
	hideUI()
	menuTransition = true
	menu = false
	player.animateMenuTransition()
	
func _on_quit_pressed() -> void:
	hideUI()
	get_tree().quit()

func _on_credits_pressed() -> void:
	creditsShown = true 
	
func _on_resume_pressed() -> void:
	hideUI()
	menuTransition = true
	player.animateMenuTransition()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Menu"):
		if inGame:
			if menu == false:
				setPauseMenu()
				menu = true
				player.animateMenuTransition(true)
			else:
				hideUI()
				menuTransition = true
				player.animateMenuTransition()

func smoothPercentage(p):
	return -0.5*cos(PI*p)+0.5

func _physics_process(delta: float) -> void:
	print(monsterTimer.time_left)
	if !reset:
		if fadeOutTimer > 0:
			fadeOutTimer -= delta*0.5
			fadeOut.color = Color(0,0,0,smoothPercentage(fadeOutTimer))
		elif fadeOut.visible:
			fadeOut.visible = false
	else:
		fadeOut.visible = true
		if fadeOutTimer < 1:
			fadeOutTimer += delta*0.5
			fadeOut.color = Color(0,0,0,smoothPercentage(fadeOutTimer))
		elif fadeOut.visible:
			get_tree().reload_current_scene()
	if creditsShown:
		credits.visible = true
		if creditsTimer < 1:
			creditsTimer += delta*0.5
			credits.modulate = Color(1,1,1,smoothPercentage(creditsTimer))
	else:
		if creditsTimer > 0:
			creditsTimer -= delta*0.5
			credits.modulate = Color(1,1,1,smoothPercentage(creditsTimer))
		else:
			credits.visible = false
	if menuTransition:
		if player.isready:
			startGame()
			menuTransition = false
			inGame = true
			menu = false
	elif !menu:
		if player:
			#find the safe area
			camp_fire = get_node("CampFire")
			# Calculate the direction vector from the player to the campfire
			var player_pos = player.global_transform.origin
			var campfire_pos = camp_fire.global_transform.origin
			var direction_to_campfire = (campfire_pos - player_pos).normalized()
			
			# Calculate the angle to the campfire in 2D space
			var angle_to_campfire = atan2(direction_to_campfire.z, direction_to_campfire.x)
			# Set the rotation of the compass arrow
			compassArrow.rotation = angle_to_campfire
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
			monsterTimer.stop()
			isRunning = false
			isRunningSpawn = false
			monsterHinted = false
			eyes.cover()
		stickScore.text = "x " + str(player.stickCounter)
	if player.getInside() == true:
		total = 2

func _on_monster_timer_timeout():
	print("Monster Timer Ran Out")
	monsterTimer.stop()
	monsterTimeAudio.play()
	if monsterTimeAudio.playing == false:
			monsterTimeAudio.play()
	spawnTimer.start()
	isRunningSpawn = true 
	player.startChase()
	eyes.uncover()
	spawnMonster()
	spawnMonster()

func _on_spawn_timer_timeout():
	total += 1
	#print(total)
	if total <= monsterCount:
		spawnMonster()
	spawnInt = max(spawnInt - intervalDecrement, minSpawnInt)
	spawnTimer.wait_time = spawnInt

func spawnMonster():
	print("Spawning Monster")
	var monster = monsterScene.instantiate()
	var dir = player.velocity.normalized()
	if dir.length() == 0:
		dir = player.transform.basis.z.normalized() * -1
	
	var spawn = player.global_transform.origin + dir * 15.0
	monster.global_transform.origin = spawn
	monster.connect("requestRespawn", Callable(self, "onRespawnRequest"))
	monsters.append(monster)
	get_tree().current_scene.add_child(monster)

func onRespawnRequest():
	print("Respawning Monster")
	spawnMonster()

# reset game
func _on_back_pressed() -> void:
	hideUI()
	reset = true
	
func _on_restart_pressed() -> void:
	hideUI()
	reset = true

func _on_player_health_changed(new_health: Variant) -> void:
	if new_health <= 0:
		setEndMenu()
		menu = true
		player.animateMenuTransition(true)
		

func _on_credits_back_pressed() -> void:
	creditsShown = false
