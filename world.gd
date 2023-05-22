extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	var texture_l_path = "res://image/icon.svg"
	$LeftImage.texture = load(texture_l_path)
	
	$LeftImage.connect("click_signal", _img_clicked)
	
func _img_clicked():
	print("wow")
