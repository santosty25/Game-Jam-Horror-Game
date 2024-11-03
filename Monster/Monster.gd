class_name Monster
extends CharacterBody3D

@onready var navigation = $NavigationAgent3D
@onready var faceDir = $FaceDirection
@onready var mesh = $MeshInstance3D
@onready var move = $Move

const SPEED = 2.0

@export var fleeDistance = 10.0
@export var fleeTime = 5.0
@export var fleeInt = 5.0
@export var turnSpeed = 4.0
@export var damageInt = 1.0
@export var damage = 5.0
@export var despawnDistance = 50.0

var player
var damageTimer = 0.0
var flee = false

var F1 = load("res://Monster/hand_1.png")
var F2 = load("res://Monster/hand_2.png")
var F3 = load("res://Monster/hand_3.png")
var F4 = load("res://Monster/hand_4.png")
var frameRate = 0.25
var frames = [F1,F2,F3,F4]
var frameCounter = 0
var currentFrame = 0
var paused = false

signal requestRespawn 

func _ready():
	# get player node
	player = get_tree().get_nodes_in_group("Player")[0]
	scale = Vector3(1.5,1.5,1.5)

func _physics_process(delta):
	if !paused:
		var dist2Player = global_transform.origin.distance_to(player.global_transform.origin)
		
		if dist2Player > despawnDistance:
			emit_signal("requestRespawn")
			print("Far Away")
			queue_free()
			return

		if player:
			if player.getInside():
				runAway(delta)
			else:
				chasePlayer(delta)
			
		frameCounter += delta
		if frameCounter > frameRate:
			frameCounter = 0
			currentFrame = (currentFrame+1)%len(frames)
			mesh.mesh.material.albedo_texture = frames[currentFrame]

func chasePlayer(delta):
	#faceDir.look_at(player.global_transform.origin, Vector3.UP)
	#rotate_y(deg_to_rad(faceDir.rotation.y * turnSpeed))
	navigation.set_target_position(player.global_transform.origin)
	var velocity = (navigation.get_next_path_position() - transform.origin).normalized() * SPEED * delta
	check_direction(velocity)
	move_and_collide(velocity)
	if move.playing == false:
		move.play()

func runAway(delta):
	fleeTime -= delta
	var runDir = (global_transform.origin - player.global_transform.origin).normalized()
	
	var runVelocity = runDir * SPEED * delta
	check_direction(runVelocity)
	move_and_collide(runVelocity)
	
	if fleeTime <= 0:
		queue_free()
		fleeTime = fleeInt
	
func check_direction(v):
	if v.x < 0:
		scale.x = -abs(scale.x)
	else:
		scale.x = abs(scale.x)

	
func _on_attack_region_body_entered(body):
	if body.is_in_group("Player"):
		player.takeDamage(1)
		queue_free()
