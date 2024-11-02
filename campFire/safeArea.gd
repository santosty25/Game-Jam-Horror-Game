extends Area3D

# Define the healing rate
var healing_rate = 1.0  # Health points per second
var player = null  # Reference to the player, to be set when the player enters the area
var monster = null

func _ready():
	# Assuming "Player" is the player's node name in the main scene
	player = get_tree().get_root().get_node("Main/Player")
	monster = get_tree().get_root().get_node("Main/Monster")
	
	if player == null:
		print("Player node not found. Check the node path.")
		
func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		print("Player entered the campfire area")
		player.setInside(true)
		
func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		print("Player left the campfire area")
		player.setInside(false)
		
func _process(delta):
	# Apply healing over time if the player is inside the radius
	var ins = player.getInside()
	if ins and player and is_instance_valid(player):
		player.health += healing_rate * delta
		#print("Player healed by", healing_rate * delta)
		#print("Players health is now", player.health)
	
