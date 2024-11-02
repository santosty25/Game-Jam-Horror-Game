class_name Monster
extends CharacterBody3D

@onready var navigation= $NavigationAgent3D
@onready var faceDir = $FaceDirection

const SPEED = 5.0
@export var turnSpeed = 4.0
@export var damageInt = 1.0

var player
var damageTimer = 0.0
var isPlayerIn = false

func _ready():
	# get player node
	player = get_tree().get_nodes_in_group("Player")[0]

func _physics_process(delta):
	faceDir.look_at(player.global_transform.origin, Vector3.UP)
	rotate_y(deg_to_rad(faceDir.rotation.y * turnSpeed))
	navigation.set_target_position(player.global_transform.origin)
	var velocity = (navigation.get_next_path_position() - transform.origin).normalized() * SPEED * delta
	move_and_collide(velocity)
	
	if isPlayerIn:
		damagePlayer(delta)
	


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
		
