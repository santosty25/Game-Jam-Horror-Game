extends AudioStreamPlayer

var fadeDuration = 1.0
var minVolume = -80
var targetVolume = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func fadeIn():
	var time = 0
	volume_db = minVolume
	play()
	while time < fadeDuration:
		volume_db = lerp(minVolume, targetVolume, time/fadeDuration )
		time += get_process_delta_time()
		#await(get_tree(), "idle_frame")
	volume_db = targetVolume

func fadeOut():
	var time = 0
	volume_db = targetVolume
	play()
	while time < fadeDuration:
		volume_db = lerp(targetVolume, minVolume, time/fadeDuration )
		time += get_process_delta_time()
		#await(get_tree(), "idle_frame")
	volume_db = targetVolume
