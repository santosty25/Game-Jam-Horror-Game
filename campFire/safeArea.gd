extends Area3D

@export var messager: Messager

signal timer_expired  # Signal to notify when timer ends

var healing_rate = 1.0  
var player = null  
var monster = null
var safe_timer = null
var player_in_interact_area = false  
var max_time = 120.0
var light_radius = null
var radius_decrease_interval = 1.0  # Time interval for radius decrease in seconds
var time_since_last_decrease = 0.0   # Time tracker
var radEverySecond = 2.5/max_time
var paused = true
var varyRadius = 0.1
var varyTimer = 0
var varyTimerMax = 2
var campFireHint = "Press (E) to put a STICK into the fire"

func _ready():
	# Assuming "Player" is the player's node name in the main scene
	player = get_tree().get_root().get_node("Main/Player")
	monster = get_tree().get_root().get_node("Main/Monster")
	messager = get_tree().get_root().get_node("Main/UI/Messager")
	
	safe_timer = $Timer
	light_radius = $"../lightRadius"
	if player == null:
		print("Player node not found. Check the node path.")
	
	safe_timer.wait_time = max_time
	safe_timer.start()
	#fix number 3

func _on_interact_area_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		#print("Player exited interact area")
		player_in_interact_area = false
		if messager:
			messager.delMessage()

# Detect when the player enters the interaction area
func _on_interact_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):  # Assumes player is part of a "Player" group
		#print("Player entered interact area")
		player_in_interact_area = true
		
		if player.stickCounter > 0:
			if messager:
				messager.setMessage(campFireHint)
			else:
				print("NIL value")

func _on_body_entered(body: Node3D) -> void:
	if safe_timer.time_left > 1:
		if body.is_in_group("Player"):
			#print("Player entered the campfire area")
			player.setInside(true)
			player.exploringAudio.playing = false
			player.restingAudio.playing = true
	else:
		if body.is_in_group("Player"):
			#print("Player entered the campfire area")
			player.setInside(false)
		
func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		#print("Player left the campfire area")
		player.setInside(false)
		player.restingAudio.playing = false
		player.exploringAudio.playing = true
		
# Function to add time to the timer
# Function to add time to the timer
func add_stick():
	# Increase timer but cap at max_time
	var timeAdded = 20
	if safe_timer.time_left < max_time:
		var difference = min(max_time, safe_timer.time_left + timeAdded)
		safe_timer.wait_time = difference
		safe_timer.start()  # Restart timer to apply updated wait time
		# Increase the light radius
		var increaseAmount = timeAdded * radEverySecond  # Calculate the increase
		var currentLightRadius = light_radius.mesh.top_radius
		light_radius.mesh.set_top_radius(currentLightRadius + increaseAmount)
		light_radius.mesh.set_bottom_radius(currentLightRadius + increaseAmount)
		player.stickCounter -= 1
		
func setLightRadius(top,bottom):
	light_radius.mesh.set_top_radius(top)
	light_radius.mesh.set_bottom_radius(bottom)
		
func _process(delta):
	# Countdown logic
	if varyTimer < varyTimerMax:
		varyTimer += delta
	else:
		varyTimer = 0
	var r = 1+varyRadius*sin(2*PI*varyTimer/varyTimerMax)
	light_radius.scale.x = r
	light_radius.scale.z = r
	
	if !paused:
		if safe_timer.time_left > 1:
			time_since_last_decrease += delta
			if time_since_last_decrease >= radius_decrease_interval:
				time_since_last_decrease = 0.0
				#decrease the light radius
				var currentLightRadius = light_radius.mesh.top_radius
				setLightRadius(currentLightRadius-radEverySecond,currentLightRadius-radEverySecond)
		else:
			#print("Expired")
			safe_timer.stop()
			player.setInside(false)
			emit_signal("timer_expired")  # Emit signal when timer expires
		
		if player_in_interact_area and Input.is_action_just_pressed("Interact") and player.stickCounter > 0:  # "interact" should be mapped to "E" in Input Map
			add_stick()
			
		# Apply healing over time if the player is inside the radius
		var ins = player.getInside()
		if ins and player and is_instance_valid(player):
			if player.health <= 3:
				player.health += healing_rate * delta
				#print("Player healed by", healing_rate * delta)
				print("Players health is now", player.health)
			#else:
				#print("Player already at max health")
