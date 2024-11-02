extends CharacterBody3D
class_name Player

const SPEED = 5.0

var stickInRange = false
var inside = false
var health = 100
var stickCounter = 0
var stix = load("res://Collectables/Stick.tscn")
var stickHint = "Press (E) to pick up STICK"

var frames = [load("res://Player/Player_1.png"),load("res://Player/Player_2.png"),load("res://Player/Player_3.png")]
var idle = frames[1]
var frameRate = 0.25
var frameCounter = 0
var currentFrame = 0

@onready var mesh = $"MeshInstance3D"
@onready var collision = $"CollisionShape3D"
@onready var camera = $Ground/Camera3D
@onready var shader = $Ground/Camera3D/Shader.mesh.material
@onready var interaction = $Interaction
@export var messager: Messager

#var inside = false

func _ready():
	pass

func _physics_process(delta: float) -> void:
	if stickInRange && Input.is_action_just_pressed("Interact"):
			stickCounter = stickCounter + 1
			print(stickCounter)
			stix.pickup()
			stickInRange = false
			
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
		
	if velocity.x < 0:
		mesh.scale.x = -abs(mesh.scale.x)
	elif velocity.x > 0:
		mesh.scale.x = abs(mesh.scale.x)
		
	if velocity.length() > 0:
		frameCounter += delta
		if frameCounter > frameRate:
			frameCounter = 0
			currentFrame = (currentFrame+1)%len(frames)
			mesh.mesh.material.albedo_texture = frames[currentFrame]
	else:
		mesh.mesh.material.albedo_texture = idle
	move_and_slide()
	
	
func takeDamage(damage):
	health -= damage
	print("Player took damage")
	
func setInside(val):
	makeOutlineWhite()
	inside = val
	
func getInside():
	return inside

func makeOutlineRed():
	shader.set("shader_parameter/threat_near",true)
func makeOutlineWhite():
	shader.set("shader_parameter/threat_near",false)

func _on_interaction_area_entered(area: Area3D) -> void:
	if area.get_parent() is Stick:
		print("Stick inside")
		stix = area.get_parent()
		stickInRange = true
		if messager:
			messager.setMessage(stickHint)

func _on_interaction_area_exited(area: Area3D) -> void:
	if area.get_parent() is Stick:
		print("Stick Gone")
		stickInRange = false
		if messager:
			messager.delMessage()
