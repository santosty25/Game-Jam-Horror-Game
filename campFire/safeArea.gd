extends Area3D

var healing_rate = 1.0  
var player = null  
var monster = null
var safe_timer = null
var player_in_interact_area = false  
var max_time = 120.0

func _ready():
	# Assuming "Player" is the player's node name in the main scene
	player = get_tree().get_root().get_node("Main/Player")
	monster = get_tree().get_root().get_node("Main/Monster")
	safe_timer = $Timer
		
	if player == null:
		print("Player node not found. Check the node path.")
	
	safe_timer.wait_time = max_time
	safe_timer.start()
	#fix number 3
	
func _on_interact_area_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		print("Player exited interact area")
		player_in_interact_area = false
	
# Detect when the player enters the interaction area
func _on_interact_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):  # Assumes player is part of a "Player" group
		print("Player entered interact area")
		player_in_interact_area = true
		
func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		print("Player entered the campfire area")
		player.setInside(true)
		
func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		print("Player left the campfire area")
		player.setInside(false)
		
# Function to add time to the timer
func add_stick():
	# Increase timer but cap at max_time
	if safe_timer.time_left < max_time:
		var difference = min(max_time, safe_timer.time_left + 20)
		safe_timer.wait_time = difference
		safe_timer.start()  # Restart timer to apply updated wait time
		print("Stick added to the fire! Timer extended to: ", safe_timer.wait_time, "seconds")
		player.stickCounter -= 1
		
func _process(delta):
	# Countdown logic
	if safe_timer.time_left > 1:
		#print("Time left in safe area:", int(safe_timer.time_left), "seconds")
		#print(player.stickCounter)
		pass
	else:
		#print("Expired")
		safe_timer.stop()
		player.setInside(false)
	
	if player_in_interact_area and Input.is_action_just_pressed("Interact"):  # "interact" should be mapped to "E" in Input Map
		add_stick()
		
	# Apply healing over time if the player is inside the radius
	var ins = player.getInside()
	if ins and player and is_instance_valid(player):
		if player.health <= 100:
			player.health += healing_rate * delta
			#print("Player healed by", healing_rate * delta)
			#print("Players health is now", player.health)
		#else:
			#print("Player already at max health")
