extends CharacterBody3D
class_name Player

const SPEED = 5.0
const ROTSPEED = 0.3
const ROTSPEEDFAST = 1
const TRANSTIME = 1

signal health_changed(new_health)  # Signal for health changes

var stickInRange = false
var inside = false
var health = 3
var maxHealth = 3
var stickCounter = 0
var stickLocation = []
var respondLoc = []
var full = false
var menu = false
# camera position y, camera position z, shader center z, camera rotation x
var gameplayConfigVals = [6, 10, -9.9, -35]
var menuConfigVals = [4, 14, -13.9, -20]
var transitionToGameplay = false
var transitionToMenu = false
var ttime = 0
var camRotStart = 0
var isready = false
var camPosStart = Vector3.ZERO

var stix = load("res://Collectables/Stick.tscn")
var stickHint = "Press (E) to pick up STICK"

var frames = [load("res://Player/Walk_1.png"),load("res://Player/Walk_2.png"),load("res://Player/Walk_3.png"),load("res://Player/Walk_4.png")]
var idle = load("res://Player/Idle.png")
var frameRate = 0.25
var frameCounter = 0
var currentFrame = 0

@onready var mesh = $"MeshInstance3D"
@onready var collision = $"CollisionShape3D"
@onready var walking = $Walking
@onready var pickup = $Pickup
@export var cameraAnchor: CameraAnchor
@onready  var camera = cameraAnchor.getCamera()
@onready var shader = cameraAnchor.getShader()
@onready var shaderObj = cameraAnchor.getShaderObj()
@onready var interaction = $Interaction
@onready var heartsContainer = $heartsContainer
@export var messager: Messager


func _ready() -> void:
	setMenu()

func setMenu():
	menu = true
	heartsContainer.visible = false
	
func setGameplay():
	menu = false
	camera.position.y = gameplayConfigVals[0]
	camera.position.z = gameplayConfigVals[1]
	shader.set("shader_parameter/center",Vector3(0,0,gameplayConfigVals[2]))
	camera.rotation_degrees.x = gameplayConfigVals[3]
	shaderObj.rotation_degrees.x = -gameplayConfigVals[3]
	cameraAnchor.rotation.y = 0
	shader.set("shader_parameter/rotation",-cameraAnchor.rotation.y)
	heartsContainer.visible = true
	
func animateMenuTransition(toMenu=false):
	ttime = 0
	camRotStart = cameraAnchor.rotation.y
	camPosStart = cameraAnchor.position
	transitionToMenu = toMenu
	transitionToGameplay = !toMenu
	if transitionToMenu:
		isready = false
		menu = true
	
func move(start, end, percent):
	var p = -0.5*cos(PI*percent)+0.5
	return (end-start)*p+start

func _physics_process(delta: float) -> void:
	if position.y > 0:
		position.y = 0
	if menu:
		if !transitionToGameplay && !transitionToMenu:
			cameraAnchor.rotate(Vector3(0,1,0),ROTSPEED*delta)
			shader.set("shader_parameter/rotation",-cameraAnchor.rotation.y)
		else:
			ttime += delta
			var p = ttime/TRANSTIME
			if transitionToGameplay:
				cameraAnchor.rotation.y = move(camRotStart,0,p)
				camera.position.y = move(menuConfigVals[0],gameplayConfigVals[0],p)
				camera.position.z = move(menuConfigVals[1],gameplayConfigVals[1],p)
				shader.set("shader_parameter/center",Vector3(0,0,move(menuConfigVals[2],gameplayConfigVals[2],p)))
				camera.rotation_degrees.x = move(menuConfigVals[3],gameplayConfigVals[3],p)
				shaderObj.rotation_degrees.x = -move(menuConfigVals[3],gameplayConfigVals[3],p)
				shader.set("shader_parameter/rotation",-cameraAnchor.rotation.y)
				cameraAnchor.position = move(camPosStart,position,p)
				if p >= 1:
					transitionToGameplay = false
					isready = true
					setGameplay()
			elif transitionToMenu:
				cameraAnchor.rotation.y = move(camRotStart,0,p)
				camera.position.y = move(gameplayConfigVals[0],menuConfigVals[0],p)
				camera.position.z = move(gameplayConfigVals[1],menuConfigVals[1],p)
				shader.set("shader_parameter/center",Vector3(0,0,move(gameplayConfigVals[2],menuConfigVals[2],p)))
				camera.rotation_degrees.x = move(gameplayConfigVals[3],menuConfigVals[3],p)
				shaderObj.rotation_degrees.x = -move(gameplayConfigVals[3],menuConfigVals[3],p)
				shader.set("shader_parameter/rotation",-cameraAnchor.rotation.y)
				cameraAnchor.position = move(camPosStart,position,p)
				if p >= 1:
					transitionToMenu = false
					setMenu()
	else:
		cameraAnchor.position = position
		if stickInRange && Input.is_action_just_pressed("Interact"):
				stickCounter = stickCounter + 1
				stix.pickup()
				pickup.play()
				stickLocation.append(stix.getPosition())
				print(stickLocation.size())
				print(stickLocation)
				print(stix.getPosition())
				if stickLocation.size() > 10:
					respondLoc = stickLocation[0]
					stickLocation = stickLocation.slice(1, 9)
					stickLocation.append(stix.getPosition())
					full = true
				else:
					full = false
				stickInRange = false
				
		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var input_dir := Input.get_vector("Left", "Right", "Up", "Down")
		var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			if walking.playing == false:
				walking.play()
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			if walking.playing == true:
				walking.stop()
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
	
func getRespondLoc():
	return respondLoc

func getFull():
	return full

func takeDamage(damage):
	health -= damage
	health = min(max(0, health),maxHealth)  # Prevent health from going below 0
	print("Player took damage. Health is now:", health)
	emit_signal("health_changed", health)  # Emit signal when health changes
	if health <= 0:
		setMenu()
		
func heal(amount):
	health += amount
	health = min(max(0, health),maxHealth)  # Prevent health from going below 0
	print("Player healed. Health is now:", health)
	emit_signal("health_changed", health)  # Emit signal when health changes
	
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
	if area.get_parent() is Stick && stickCounter < 5:
		stix = area.get_parent()
		stickInRange = true
		if messager:
			messager.setMessage(stickHint)

func _on_interaction_area_exited(area: Area3D) -> void:
	if area.get_parent() is Stick:
		stickInRange = false
		if messager:
			messager.delMessage()
