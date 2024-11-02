class_name Monster
extends CharacterBody3D

@onready var navigation= $NavigationAgent3D
@onready var faceDir = $FaceDirection

const SPEED = 5.0
@export var turnSpeed = 4.0

var player

func _ready():
	# get player node
	player = get_tree().get_nodes_in_group("Player")[0]

func _physics_process(delta):
	faceDir.look_at(player.global_transform.origin, Vector3.UP)
	rotate_y(deg_to_rad(faceDir.rotation.y * turnSpeed))
	navigation.set_target_position(player.global_transform.origin)
	var velocity = (navigation.get_next_path_position() - transform.origin).normalized() * SPEED * delta
	move_and_collide(velocity)
	
