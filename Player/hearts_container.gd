extends HBoxContainer

@onready var heart1 = $heart1 
@onready var heart2 = $heart2
@onready var heart3 = $heart3

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
	heart1.visible = new_health >= 1
	heart2.visible = new_health >= 2
	heart3.visible = new_health >= 3
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
