class_name Monster
extends CharacterBody3D

@onready var navigation= $NavigationAgent3D
@onready var faceDir = $FaceDirection

const SPEED = 1.0

@export var fleeDistance = 10.0
@export var fleeTime = 5.0
@export var fleeInt = 5.0
@export var turnSpeed = 4.0
@export var damageInt = 1.0
@export var damage = 5.0

var player
var damageTimer = 0.0
var isPlayerIn = false
var flee = false

func _ready():
	# get player node
	player = get_tree().get_nodes_in_group("Player")[0]

func _physics_process(delta):
	
	if player:
		if player.getInside():
			runAway(delta)
		else:
			chasePlayer(delta)

	if isPlayerIn:
		damagePlayer(delta)

func chasePlayer(delta):
	faceDir.look_at(player.global_transform.origin, Vector3.UP)
	rotate_y(deg_to_rad(faceDir.rotation.y * turnSpeed))
	navigation.set_target_position(player.global_transform.origin)
	var velocity = (navigation.get_next_path_position() - transform.origin).normalized() * SPEED * delta
	move_and_collide(velocity)

func runAway(delta):
	fleeTime -= delta
	var runDir = (global_transform.origin - player.global_transform.origin).normalized()
	
	var runVelocity = runDir * SPEED * delta
	move_and_collide(runVelocity)
	
	if fleeTime <= 0:
		queue_free()
		fleeTime = fleeInt
	
func _on_attack_region_body_entered(body):
	if body.is_in_group("Player"):
		isPlayerIn = true
		print("Player in range")

func _on_attack_region_body_exited(body):
	if body.is_in_group("Player"):
		isPlayerIn = false
		print("Player out of range")

func damagePlayer(delta):
	damageTimer -= delta
	if damageTimer <= 0:
		# reset timer
		damageTimer = damageInt
		player.takeDamage(damage)
