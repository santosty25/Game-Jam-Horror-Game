extends Label
class_name Messager

var typeRate = 0.05
var typeTimer = 0
var disappearRate = 0.01
var charCounter = 0

var function = 0 # nothing, write, delete
var message = ""

func _physics_process(delta: float) -> void:
	if function == 1:
		if typeTimer < typeRate:
			typeTimer += delta
		elif charCounter < len(message):
			charCounter += 1
			typeTimer = 0
			text = message.substr(0,charCounter)
	if function == 2:
		if len(text) > 0:
			if typeTimer < disappearRate:
				typeTimer += delta
			else:
				typeTimer = 0
				text = text.substr(0,max(len(text)-2,0))
	else:
		pass
		
func setMessage(m):
	charCounter = 0
	function = 1
	if len(text) != 0:
		clearMessage()
	message = m

func delMessage():
	function = 2

func clearMessage():
	text = ""
