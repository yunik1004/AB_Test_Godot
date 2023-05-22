extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	$Label.text = "# Correct: %d\n# Wrong: %d" % [Global.num_correct, Global.total_round - Global.num_correct]
