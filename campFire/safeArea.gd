extends Area3D

# Define the healing rate
var healing_rate = 1.0  # Health points per second
var player = null  # Reference to the player, to be set when the player enters the area

func _ready():
	# Assuming "Player" is the player's node name in the main scene
	player = get_tree().get_root().get_node("Main/Player")
	if player == null:
		print("Player node not found. Check the node path.")

func _on_Area_body_entered(body):
	# Check if the entered body is the player
	if body == player:
		print("Player entered the campfire area")

func _on_Area_body_exited(body):
	# Stop healing when the player leaves
	if body == player:
		print("Player exited the campfire area")

func _process(delta):
	# Apply healing over time if the player is in the radius
	if player and is_instance_valid(player):
		player.health += healing_rate * delta
		print("Player healed by", healing_rate * delta)
