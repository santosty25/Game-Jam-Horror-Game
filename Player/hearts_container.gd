extends HBoxContainer

@onready var heart1 = $heart1 
@onready var heart2 = $heart2
@onready var heart3 = $heart3

var heartFull = load("res://Player/Bone.png")
var heartEmpty = load("res://Player/Bone_Broken.png")

var player = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Get the player node
	player = get_tree().get_root().get_node("Main/Player")  # Adjust path as needed
	if player:
		# Connect to the player's health_changed signal
		player.connect("health_changed", Callable(self, "_on_health_changed"))
		# Initialize hearts display
		_on_health_changed(player.health)
	else:
		print("Player node not found. Check the node path.")

func _on_health_changed(new_health):
	# Show or hide hearts based on player's current health
	var hearts = [heart3,heart2,heart1]
	for i in range(len(hearts)):
		if len(hearts)-new_health > i:
			hearts[i].texture = heartEmpty
		else:
			hearts[i].texture = heartFull
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
