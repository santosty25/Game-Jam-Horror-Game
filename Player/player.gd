extends CharacterBody3D
class_name Player


const SPEED = 5.0

var stickInRange = null

var health = 100

@export var player: Player
var stix

@onready var mesh = $"MeshInstance3D"
@onready var collision = $"CollisionShape3D"
@onready var camera = $"Camera3D"

var inside = false

func _ready():
	stix = get_node("Stick")

	
func _physics_process(delta: float) -> void:
	
	if stickInRange && Input.is_action_just_pressed("Interact"):
		stickInRange.pickup()
		stickInRange = null
		

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("Left", "Right", "Up", "Down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
func stick_nearby():
	stickInRange = true
	
func takeDamage(damage):
	health -= damage
	print("Player took damage")
	
func setInside(val):
	inside = val
	
func getInside():
	return inside
