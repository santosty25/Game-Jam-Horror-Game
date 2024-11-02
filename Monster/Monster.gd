class_name Monster
extends CharacterBody3D

@onready var navigation: NavigationAgent3D = $NavigationAgent3D
@onready var faceDir: Node3D = $FaceDirection

const speed = 5.0
const turnSpeed = 4.0

var player: CharacterBody3D = null

func _ready():
	# get player node
	player = get_parent().get_node("Player")

func _physics_process(delta):
	faceDir.look_at(player.global_transform.origin, Vector3.UP)
	rotate_y(deg_to_rad(faceDir.rotateion.y * turnSpeed))
	navigation.set_target_postion(player.global_transform.origin)
	var velocity = (navigation.get_next_path_position() - transform.origin).normalized() * speed * delta
	move_and_collide(velocity)
	
