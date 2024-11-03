extends Node3D
class_name Campfire

@onready var sprite = $Sprite
@onready var safe_area = $safeArea  
@onready var timer = $safeArea/Timer 
@export var messager: Messager 
var t1 = load("res://campFire/Fire_1.png")
var t2 = load("res://campFire/Fire_2.png")
var t3 = load("res://campFire/Fire_3.png")
var flickerTime = 0.5
var flickerCounter = 0
var t = true
var timerEnd = false
var fireHinted = false

signal fire_extinguished

var fireTimeLow = "Your fire will die soon"

func setMenu():
	timer.paused = true
	safe_area.paused = true
	
func setGameplay():
	timer.paused = false
	safe_area.paused = false

func _ready():
	# Connect to safeArea's timer_expired signal
	safe_area.connect("timer_expired", Callable(self, "_on_timer_expired"))
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if timer.time_left > 10:
		fireHinted = false
	elif !fireHinted:
		messager.setMessage(fireTimeLow)
		fireHinted = true
	if !timerEnd:
		flickerCounter += delta
		if flickerCounter > flickerTime:
			t = !t
			flickerCounter = 0
			if t:
				sprite.mesh.material.albedo_texture = t1
			else:
				sprite.mesh.material.albedo_texture = t2
	else:
		sprite.mesh.material.albedo_texture = t3
		
# Handle the timer expiration
func _on_timer_expired():
	timerEnd = true
	$OmniLight3D.light_energy = 0

func _on_safe_area_timer_expired() -> void:
	if $interactArea:
		$interactArea.queue_free()
	emit_signal("fire_extinguished")
