extends Area3D

# Define the healing rate
var healing_rate = 5.0  # Health points per second
var healing_active = false  # Tracks if healing should be applied

func _on_Area_body_entered(body):
	# Check if the entered body is the player
	if body.name == "Player":
		healing_active = true  # Start healing when the player enters the area

func _on_Area_body_exited(body):
	# Stop healing when the player leaves
	if body.name == "Player":
		healing_active = false

func _process(delta):
	# Apply healing over time if the player is in the radius
	if healing_active:
		# Assumes the player has a "health" property that can be increased
		get_node("Player").health += healing_rate * delta
